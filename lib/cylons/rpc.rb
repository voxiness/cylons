require 'ransack'
module Cylons
  module RPC
    extend ::ActiveSupport::Concern
    
    included do
      include ::ActiveModel::Dirty
      include ::Cylons::Attributes
      
      def all
        execute(:all)
      end
      
      def create(params)
        execute(:create, params)
      end
      
      def execute(rpc_method, request_params = {})
        begin
          @last_response = self.class.model.send(rpc_method.to_sym, request_params)
        rescue => e
          @last_response = {:error => e.message}
        end

        @last_response
      end
      
      def execute_with_args(rpc_method, *args)
        begin
          @last_response = self.class.model.send(rpc_method.to_sym, *args)
        rescue => e
          puts e.inspect
          puts e.message
          puts @last_response.inspect
          @last_response = {:error => e.message}
        end
      end
      
      def find(id)
        execute(:find, id)
      end
      
      def first
        execute(:first)
      end
      
      def first_or_create(params)
        execute(:first_or_create, params)
      end

      def last
        execute(:last)
      end
      
      #todo: Refactor this, hacky
      def search(params)
        response = execute(:search, params)
        
        if response.respond_to?(:result)
          return response.result.to_a
        else
          return response
        end
      end
      
      def scope_by(params)
        execute(:scope_by, params).to_a
      end
      
      def save(id, attributes)
        execute_with_args(:update, id, attributes)
      end
      
      def update(attributes)
        execute_with_args(:update, attributes.keys, attributes.values)
      end      
    end
  end
end