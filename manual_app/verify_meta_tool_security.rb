# manual_app/verify_meta_tool_security.rb
require_relative 'config/environment'

puts 'Verifying MetaToolService Security...'

service = Tools::MetaToolService.new

# 1. Verify 'register' action is removed from public API
puts "1. Checking 'register' action removal..."
result = service.call(action: 'register')
if result[:error] && result[:error].include?('Unknown action')
  puts "✅ 'register' action is correctly rejected: #{result[:error]}"
else
  puts "❌ 'register' action was NOT rejected: #{result}"
  exit 1
end

# 2. Verify register_tool is public and works
puts '2. Checking register_tool public access...'
# We need a dummy class to register
module Tools
  class SecurityTestService
    extend T::Sig
    extend ToolMeta
    tool_name 'security_test'
    tool_description 'Security test'
    sig { returns(String) }
    def call
      'secure'
    end
  end
end

begin
  result = service.register_tool('Tools::SecurityTestService')
  if result[:status] == 'registered'
    puts "✅ register_tool called successfully: #{result}"
  else
    puts "❌ register_tool failed: #{result}"
    exit 1
  end
rescue NoMethodError
  puts '❌ register_tool is NOT public (NoMethodError)'
  exit 1
end

puts '🎉 All security verifications passed!'
