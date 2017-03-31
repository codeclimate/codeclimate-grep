RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

def write_test_file(content, file_name = "test.txt")
  full_path = File.join(dir, file_name)
  dir_path = File.dirname(full_path)
  FileUtils.mkdir_p(dir_path) unless Dir.exist? dir_path
  File.write(
    full_path,
    content
  )
end
