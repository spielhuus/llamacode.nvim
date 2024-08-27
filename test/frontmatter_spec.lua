local fm = require("llamacode.frontmatter")

describe("encode and decode frontmatter", function()
  it("test_encode_values", function()
        local result = fm.encode_frontmatter({model = "llama", name = "coder"});
          assert.same(result, {
            "model: llama",
            "name: coder",
          })
  end)

  it("test_encode_dict", function()
        local result = fm.encode_frontmatter({model = "llama", name = "coder", prompt = { role = "user" }});
          assert.same(result, {
            "model: llama",
            "name: coder",
            "prompt:", "  role: user",
          })
  end)

  it("test_encode_dict", function()
        local result = fm.encode_frontmatter({model = "llama", name = "coder", stream = true, prompt = { role = "user" }});
          assert.same(result, {
            "model: llama",
            "name: coder",
            "stream: true",
            "prompt:", "  role: user",
          })
  end)

  it("test_encode_dict", function()
        local result = fm.encode_frontmatter({model = "llama", name = "coder", prompt = { 1, 2, 3 }});
          assert.same(result, {
            "model: llama",
            "name: coder",
            "prompt:", "  - 1", "  - 2", "  - 3",
          })
  end)

  it("test_encode_string", function()
    assert.same(
        {"name: Brian", "prompt: |", "  you are an", "  helpful", "  assistant"},
        fm.encode_frontmatter({name = "Brian", prompt = "you are an\nhelpful\nassistant"}))
  end)
  
  it("test_decode_dict", function()
        local result = fm.decode_frontmatter({"model: llama", "name: coder", "prompt:", "  role: user" });
        print("Result:" .. vim.inspect(result))
          assert.same(result, {
            model = "llama",
            name = "coder",
            prompt =  { role = "user" }
          })
  end)

  it("test_decode_dict_bool", function()
        local result = fm.decode_frontmatter({"model: llama", "name: coder", "stream: true", "prompt:", "  role: user" });
        print("Result:" .. vim.inspect(result))
          assert.same(result, {
            model = "llama",
            name = "coder",
            stream = true,
            prompt =  { role = "user" }
          })
  end)
end)
