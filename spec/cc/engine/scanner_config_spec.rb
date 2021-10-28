require "spec_helper"
require "tmpdir"
require "cc/engine/scanner_config"

RSpec.describe CC::Engine::ScannerConfig do
  it "validates pattern presence" do
    expect do
      described_class.new(
        { "annotation" => "Found it!" },
        "null-pattern",
      )
    end.to raise_error(described_class::InvalidConfigError, "Pattern is missing from null-pattern")
  end

  it "validates annotation presence" do
    expect do
      described_class.new(
        { "pattern" => "pattern" },
        "null-annotation",
      )
    end.to raise_error(described_class::InvalidConfigError, "Annotation is missing from null-annotation")
  end

  it "validates severity" do
    expect do
      described_class.new(
        {
          "pattern" => "pattern",
          "annotation" => "Take Cover!",
          "severity" => "RED ALERT",
        },
        "invalid-severity",
      )
    end.to raise_error(described_class::InvalidConfigError, %(Invalid severity "RED ALERT" for invalid-severity. Must be one of the following: info, minor, major, critical, blocker))
  end

  it "validates category" do
    expect do
      described_class.new(
        {
          "pattern" => "ack",
          "annotation" => "Ack-Ack!!!",
          "categories" => ["Invasion"],
        },
        "invalid-category",
      )
    end.to raise_error(described_class::InvalidConfigError, %(Invalid category "Invasion" for invalid-category. Must be one of the following: Bug Risk, Clarity, Compatibility, Complexity, Duplication, Performance, Security, Style))
  end

  it "validates matcher" do
    expect do
      described_class.new(
        {
          "pattern" => "ack",
          "annotation" => "Ack-Ack!!!",
          "matcher" => "madeup"
        },
        "invalid-matcher",
      )
    end.to raise_error(described_class::InvalidConfigError, %(Invalid matcher "madeup" for invalid-matcher. Must be one of the following: fixed, basic, extended, perl))
  end

  it "defaults severity to minor" do
    config = described_class.new(
      {
        "pattern" => "test",
        "annotation" => "Found it!",
      },
      "default-severity",
    )
    expect(config.severity).to eq "minor"
  end

  it "defaults categories to Bug Risk" do
    config = described_class.new(
      {
        "pattern" => "test",
        "annotation" => "Found it!",
      },
      "default-categories",
    )
    expect(config.categories).to eq ["Bug Risk"]
  end

  it "defaults matcher to extended" do
    config = described_class.new(
      {
        "pattern" => "test",
        "annotation" => "Found it!",
      },
      "default-matcher"
    )
    expect(config.matcher_option).to eq "--extended-regexp"
  end
end
