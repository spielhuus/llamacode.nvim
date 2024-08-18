# LlamaCode

LLamacode is a neovim plugin for ollama and llamacpp integration into neovim. 
with llamacode you can create your own prompts and content receiver. 

There are util function to receive content:

get the entire buffer:

```lua
M.GetBuffer = function(buf)
```

get the code block under the cursor.

```lua
M.GetCodeBlock = function()
```

get the visual selection


```lua
M.GetBlock = function(buf_nr, start, last)
```
