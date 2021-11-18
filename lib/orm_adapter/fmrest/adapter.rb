# frozen_string_literal: true

# ORM adaptor for Filmaker Rest
require 'fmrest'

module FmRest
  module Spyke
    class Base
      extend OrmAdapter::ToAdapter

      class OrmAdapter < ::OrmAdapter::Base

        # Get a list of the attribute names (field names) in the Filemaker Layout.
        # Map attribute names
        def column_names
          return [] unless klass.respond_to? :layout

          field_meta = layout_meta klass.layout
          fields = field_meta.map{|f| f['name']}
          return fields unless klass.respond_to? :mapped_attributes

          # map attribute names
          fields + klass.mapped_attributes.keys - klass.mapped_attributes.values
        end

        # Get an instance by id of the model. Raises an error if a model is not found.
        # This should comply with ActiveModel#to_key API, i.e.:
        #
        #   User.to_adapter.get!(@user.to_key) == @user
        #
        def get!(id)
          klass.find wrap_key(id)
        end

        # Get an instance by id of the model. Returns nil if a model is not found.
        # This should comply with ActiveModel#to_key API, i.e.:
        #
        #   User.to_adapter.get(@user.to_key) == @user
        #
        def get(id)
          klass.find wrap_key(id)
        rescue FmRest::APIError::RecordMissingError
          nil
        end

        # Find the first instance, optionally matching conditions, and specifying order
        #
        # You can call with just conditions, providing a hash
        #
        #   User.to_adapter.find_first :name => "Fred", :age => 23
        #
        # Or you can specify :order, and :conditions as keys
        #
        #   User.to_adapter.find_first :conditions => {:name => "Fred", :age => 23}
        #   User.to_adapter.find_first :order => [:age, :desc]
        #   User.to_adapter.find_first :order => :name, :conditions => {:age => 18}
        #
        # When specifying :order, it may be
        # * a single arg e.g. <tt>:order => :name</tt>
        # * a single pair with :asc, or :desc as last, e.g. <tt>:order => [:name, :desc]</tt>
        # * an array of single args or pairs (with :asc or :desc as last), e.g. <tt>:order => [[:name, :asc], [:age, :desc]]</tt>
        #
        def find_first(options = {})
          base_relation(options).first
        end

        # Find all models, optionally matching conditions, and specifying order
        # @see OrmAdapter::Base#find_first for how to specify order and conditions
        # @return Enumerable
        def find_all(options = {})
          base_relation(options)
        end

        # Create a model using attributes
        def create!(attributes = {})
          klass.new(attributes).save
        end

        # Destroy an instance by passing in the instance itself.
        def destroy(object)
          object.destroy if valid_object?(object)
        end

        private

        # FmRest with converted query and sort parameters
        # @return FmRest::Spyke::Relation
        def base_relation(options)
          conditions, order, limit, offset = extract_conditions!(options)

          relation = klass.query(exact_conditions(conditions))
          relation = relation.sort(*order_clause(order)) if order.any?
          relation = relation.limit(limit) if limit
          relation = relation.offset(offset) if offset

          relation
        end

        def exact_conditions(conditions)
          conditions.transform_values { |v| v.is_a?(String) ? "==#{v}" : v }
        end

        def order_clause(order)
          order.map {|col, dir| (dir == :desc ? "#{col}__desc" : col).to_sym }
        end

        # given an order argument, returns an array of attributes (symbols) postfixed with __desc if order is reversed
        def normalize_order(order)
          if order.is_a? Array
            order = [order] unless order.first.is_a?(Array)
            order.map { |key, dir| (dir.to_s.downcase == 'desc' ? "key__desc" : key).to_sym }
          else
            [order.to_sym]
          end
        end

        # request field meta data for layout of resource class
        def layout_meta(layout)
          FmRest::V1.build_connection(klass.try(:fmrest_config))
                    .get("layouts/#{layout}")
                    .body.dig('response', 'fieldMetaData')
        end
      end

    end
  end
end
