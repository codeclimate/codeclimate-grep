require "spec_helper"
require "tmpdir"
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

  def write_test_file(content)
    File.write(
      File.join(dir, "test.txt"),
      content
    )
  end

  it "finds matches" do
    write_test_file "test string"
    io = StringIO.new
    grep = described_class.new(
      root: dir,
      config: {
        "config" => {
          "patterns" => ["test"],
          "message" => "Found it!"
        }
      },
      io: io
    )

    grep.run

    expect(io.string).to eq %({"type":"issue","check_name":"Pattern Match","description":"","categories":["Bug Risk"],"location":{"path":"./test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":5}}},"severity":"info"}\n\u0000)
  end

  it "finds multiple matches" do
    write_test_file "test string is a test"
    io = StringIO.new
    grep = described_class.new(
      root: dir,
      config: {
        "config" => {
          "patterns" => ["test"],
          "message" => "Found it!"
        }
      },
      io: io
    )

    grep.run

    expect(io.string).to include %({"type":"issue","check_name":"Pattern Match","description":"","categories":["Bug Risk"],"location":{"path":"./test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":5}}},"severity":"info"}\n\u0000)
    expect(io.string).to include %({"type":"issue","check_name":"Pattern Match","description":"","categories":["Bug Risk"],"location":{"path":"./test.txt","positions":{"begin":{"line":1,"column":18},"end":{"line":1,"column":22}}},"severity":"info"}\n\u0000)
  end

  it "is OK to find nothing" do
    write_test_file "A capacity, and taste, for reading gives access to whatever has already been discovered by others."
    io = StringIO.new
    grep = described_class.new(
      root: dir,
      config: {
        "config" => {
          "patterns" => ["test"],
          "message" => "Found it!"
        }
      },
      io: io
    )

    grep.run

    expect(io.string).to eq ""
  end

  it "understands extende regular experssions" do
    write_test_file "cat or dog"
    io = StringIO.new
    grep = described_class.new(
      root: dir,
      config: {
        "config" => {
          "patterns" => ["cat|dog"],
          "message" => "Found it!"
        }
      },
      io: io
    )

    grep.run

    expect(io.string).to include %({"type":"issue","check_name":"Pattern Match","description":"","categories":["Bug Risk"],"location":{"path":"./test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":4}}},"severity":"info"}\n\u0000)
    expect(io.string).to include %({"type":"issue","check_name":"Pattern Match","description":"","categories":["Bug Risk"],"location":{"path":"./test.txt","positions":{"begin":{"line":1,"column":8},"end":{"line":1,"column":11}}},"severity":"info"}\n\u0000)
  end
end
