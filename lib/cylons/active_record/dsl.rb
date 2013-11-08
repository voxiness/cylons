require 'cylons/remote_discovery'

module Cylons
  module ActiveRecord
    module DSL
      SEARCH_OPTION_KEYS = [:opts, :options].freeze
      MAX_PER_PAGE = 1000
      
      def remote_attribute(name, options = {})
        registered_remote_attributes << {:name => name}.merge(options)
      end
      
      def remote_attributes(*args)
        options = args.extract_options!
        
        args.each do |arg|
          remote_attribute(arg, options)
        end
      end
      
      def reload_remotes!
        ::Cylons::RemoteDiscovery.load_remotes unless ::Cylons.silence?
      end
      
      def remote_schema
        ::Cylons::RemoteRegistry.get_remote_schema(self.name) unless ::Cylons.silence?
      end
      
      def remote_belongs_to(*args)
        options = args.extract_options!
        
        args.each do |arg|
          options[:foreign_key] = "#{arg}_id"
          association_hash = {:name => arg, :association_type => :belongs_to, :options => options}
          self.remote_associations << association_hash
          build_remote_belongs_to_association(association_hash)
        end
      end
      
      #store remote has many assoc globally, then define it locally. 
      def remote_has_many(*args)
        options = args.extract_options!
        
        args.each do |arg|
          association_hash = {:name => arg, :association_type => :has_many, :options => options}
          self.remote_associations << association_hash
          build_remote_has_many_association(association_hash)
        end
      end
      
      #TODO: Hacky, but something strange is going on here, and syntax will need to chagne for rails4... hrmmm
      def scope_by(params = {})
        search_options = params.extract!(*SEARCH_OPTION_KEYS)
        
        search_options.delete_if {|k,v| v.nil? }
        
        if search_options.present?
          scoped_search = params.inject(scoped) do |combined_scope, param|
            combined_scope.send("by_#{param.first}", param.last)
          end.paginate(:page => search_options[:options][:page], :per_page => search_options[:options][:per_page])
        else
          scoped_search = params.inject(scoped) do |combined_scope, param|
            combined_scope.send("by_#{param.first}", param.last)
          end.paginate(:page => 1, :per_page => MAX_PER_PAGE)
        end
        
        scoped_search
      end      
    end
  end
end