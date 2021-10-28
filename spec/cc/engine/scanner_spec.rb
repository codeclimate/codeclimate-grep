require "spec_helper"
require "tmpdir"
require "cc/engine/scanner"

RSpec.describe CC::Engine::Scanner do
  let(:stash) {{}}
  let(:dir) { stash[:dir] }
  around(:each) do |example|
    Dir.mktmpdir do |dir|
      stash[:dir] = dir
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  it "finds matches" do
    write_test_file "test string"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test-match",
      config: {
        "pattern" => "test",
        "annotation" => "Found it!"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to eq %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":5}}},"severity":"minor"}\n\u0000)
  end

  it "finds multiple matches" do
    write_test_file "test string is a test"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test-match",
      config: {
        "pattern" => "test",
        "annotation" => "Found it!"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":5}}},"severity":"minor"}\n\u0000)
    expect(io.string).to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":18},"end":{"line":1,"column":22}}},"severity":"minor"}\n\u0000)
  end

  it "is OK to find nothing" do
    write_test_file "A capacity, and taste, for reading gives access to whatever has already been discovered by others."
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test-match",
      config: {
        "pattern" => "test",
        "annotation" => "Found it!"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to eq ""
  end

  it "understands extended regular expressions by default" do
    write_test_file "cat or dog"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test-match",
      config: {
        "pattern" => "cat|dog",
        "annotation" => "Found it!"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":4}}},"severity":"minor"}\n\u0000)
    expect(io.string).to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":8},"end":{"line":1,"column":11}}},"severity":"minor"}\n\u0000)
  end

  it "can be configured for perl regular expressions" do
    write_test_file "match me\nmatch me not here"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test-match",
      config: {
        "regexp" => "perl",
        "pattern" => "^match me(?! not here)",
        "annotation" => "Found it!"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":9}}},"severity":"minor"}\n\u0000)
    expect(io.string).not_to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":2,"column":9},"end":{"line":2,"column":9}}},"severity":"minor"}\n\u0000)
  end

  it "can be configured for basic matches" do
    write_test_file "cat or dog"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test-match",
      config: {
        "regexp" => "basic",
        "pattern" => "cat\\|dog",
        "annotation" => "Found it!"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":4}}},"severity":"minor"}\n\u0000)
    expect(io.string).to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":8},"end":{"line":1,"column":11}}},"severity":"minor"}\n\u0000)
  end

  it "can be configured for \"fixed string\" matches" do
    write_test_file "cat|dog"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test-match",
      config: {
        "regexp" => "fixed",
        "pattern" => "cat|dog",
        "annotation" => "Found it!"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"test-match","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":8}}},"severity":"minor"}\n\u0000)
  end

  it "includes content when available" do
    write_test_file "test"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "content",
      config: {
        "pattern" => "test",
        "annotation" => "Found it!",
        "content" => "content body"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"content","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":5}}},"severity":"minor","content":{"body":"content body"}}\n\u0000)
  end

  it "uses categories from config" do
    write_test_file "test"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test",
      config: {
        "pattern" => "test",
        "annotation" => "Found it!",
        "categories" => ["Clarity", "Style"]
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"test","description":"Found it!","categories":["Clarity","Style"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":5}}},"severity":"minor"}\n\u0000)
  end

  it "uses severity from config" do
    write_test_file "test"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test",
      config: {
        "pattern" => "test",
        "annotation" => "Found it!",
        "severity" => "info"
      },
      paths: ["test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"test","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":5}}},"severity":"info"}\n\u0000)
  end

  it "filters paths with path_patterns" do
    write_test_file "test", "test/test.txt"
    write_test_file "test", "skip/skip.txt"
    io = StringIO.new
    scanner = described_class.new(
      check_name: "test",
      config: {
        "pattern" => "test",
        "annotation" => "Found it!",
        "path_patterns" => ["**/test.txt"]
      },
      paths: ["skip/skip.txt", "test/test.txt"],
      io: io
    )

    scanner.run

    expect(io.string).to include %({"type":"issue","check_name":"test","description":"Found it!","categories":["Bug Risk"],"location":{"path":"test/test.txt","positions":{"begin":{"line":1,"column":1},"end":{"line":1,"column":5}}},"severity":"minor"}\n\u0000)
    expect(io.string).to_not include "skip.txt"
  end
end
