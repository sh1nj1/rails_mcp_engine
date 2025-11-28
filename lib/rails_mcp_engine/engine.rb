require 'rails'
require 'ruby_llm'
require 'fast_mcp'

module RailsMcpEngine
  class Engine < ::Rails::Engine
    # Define the base class expected by the engine, inheriting from the real gem
    # This ensures ApplicationTool is available to the host app and the engine
    initializer 'rails_mcp_engine.define_base_class' do
      unless defined?(::ApplicationTool)
        class ::ApplicationTool < FastMcp::Tool
        end
      end
    end

    # Trigger tool generation on boot and reload
    config.to_prepare do
      # Ensure engine files are loaded
      # We might need to explicitly require them if autoloading doesn't pick them up immediately
      # or rely on Rails autoloading if paths are set correctly.

      # The engine's app/lib and app/services are automatically added to paths by Rails Engine mechanism.

      # We need to make sure ToolMeta and factories are loaded before we use them.
      # Since they are in app/lib, they should be autoloadable.

      # However, to iterate over registry, we need the service classes to be loaded.
      # Rails eager_load should handle this in production. In development, we might need to force load?
      # For now, let's assume the user defines tools in app/services/tools/ which are autoloaded.

      # But wait, ToolMeta.registry is populated when classes are *defined*.
      # If classes are not loaded, registry is empty.
      # Rails `to_prepare` runs before requests.

      # Let's keep the logic from the original initializer.

      # We need to require the builder/factories here to ensure they are available
      # or trust autoloading. Let's trust autoloading but reference them to trigger it.

      # NOTE: In the original initializer, it required them relative to the file.
      # Here we should rely on autoloading constants.

      # Iterate through registered tools and build them.
      # Note: This assumes service classes have been loaded.
      # If they are in the host app, they might not be loaded yet in `to_prepare` unless eager_loaded.
      # But `to_prepare` is the standard place for this.

      ToolMeta.registry.each do |service_class|
        schema = ToolSchema::Builder.build(service_class)
        ToolSchema::RubyLlmFactory.build(service_class, schema)
        ToolSchema::FastMcpFactory.build(service_class, schema)
      end
    end
  end
end
