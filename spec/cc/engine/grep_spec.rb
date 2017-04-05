require "spec_helper"
require "tmpdir"
require "fileutils"
require "cc/engine/grep"

RSpec.describe CC::Engine::Grep do
  let(:stash) {{}}
  let(:dir) { stash[:dir] }
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      stash[:dir] = dir
      example.run
    end
  end

  it "invokes scanner for each pattern" do
    write_test_file "test"
    pattern1_config = instance_double("Pattern 1 Config")
    pattern2_config = instance_double("Pattern 2 Config")
    config = {
      "include_paths" => ["test.txt"],
      "config" => {
        "patterns" => {
          "pattern-1" => pattern1_config,
          "pattern-2" => pattern2_config
        }
      }
    }
    io = StringIO.new
    scanner_double = instance_double(CC::Engine::Scanner, run: nil)
    allow(CC::Engine::Scanner).to receive(:new).and_return(scanner_double)

    grep = described_class.new(
      root: dir,
      config: config,
      io: io
    )

    grep.run

    expect(CC::Engine::Scanner).to have_received(:new).with(
      check_name: "pattern-1",
      config: pattern1_config,
      paths: ["test.txt"],
      io: io
    )
    expect(CC::Engine::Scanner).to have_received(:new).with(
      check_name: "pattern-2",
      config: pattern2_config,
      paths: ["test.txt"],
      io: io
    )
  end

  it "passes expanded include_paths to scanner" do
    write_test_file "test 1", "dir/test1.txt"
    write_test_file "test 2", "dir/test2.txt"
    config = {
      "include_paths" => ["dir/"],
      "config" => {
        "patterns" => {
          "pattern" => {}
        }
      }
    }
    io = StringIO.new
    scanner_double = instance_double(CC::Engine::Scanner, run: nil)
    allow(CC::Engine::Scanner).to receive(:new).and_return(scanner_double)

    grep = described_class.new(
      root: dir,
      config: config,
      io: io
    )

    grep.run

    expect(CC::Engine::Scanner).to have_received(:new).with(
      check_name: "pattern",
      config: {},
      paths: ["dir/test1.txt", "dir/test2.txt"],
      io: io
    )
  end

  it "handles exception in scanner" do
    config = {
      "include_paths" => ["test.txt"],
      "config" => {
        "patterns" => {
          "pattern-1" => {},
        }
      }
    }
    io = StringIO.new

    grep = described_class.new(
      root: dir,
      config: config,
      io: io
    )

    expect do
      expect do
        grep.run
      end.to raise_error(CC::Engine::ScannerConfig::InvalidConfigError)
    end.to output("Pattern is missing from pattern-1\n").to_stderr
  end
end
