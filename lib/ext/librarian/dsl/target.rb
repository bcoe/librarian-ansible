require 'librarian/spec'

# Overrid the default librarian DSL to pass the name
# value to sources.
module Librarian
  class Dsl
    class Target

      def dependency(name, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        source = source_from_options(options, name) || @source
        dep = dependency_type.new(name, args, source)
        @dependencies << dep
      end

      def source_from_options(options, name = nil)
        if options[:source]
          source_shortcuts[options[:source]]
        elsif source_parts = extract_source_parts(options, name)
          source_from_params(*source_parts)
        else
          nil
        end
      end

      def extract_source_parts(options, name = nil)
        options = {:galaxy => name} if options.empty?

        if name = source_type_names.find{|name| options.key?(name)}
          options = options.dup
          param = options.delete(name)
          [name, param, options]
        else
          nil
        end
      end

    end
  end
end
