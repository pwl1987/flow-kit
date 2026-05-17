"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/server.mjs
var server_exports = {};
__export(server_exports, {
  createServer: () => createServer,
  main: () => main
});
module.exports = __toCommonJS(server_exports);
var import_path = require("path");
var import_module = require("module");
var import_meta = {};
var require2 = (0, import_module.createRequire)(import_meta.url);
function createServer(options = {}) {
  const {
    name = "flow-kit",
    version = "3.8.0"
  } = options;
  const sdkPath = (0, import_path.join)((0, import_path.dirname)(require2.resolve("@modelcontextprotocol/sdk")), "esm/index.js");
  let ServerClass, StdioServerTransport;
  return {
    server: {
      name,
      version,
      tool: () => {
      },
      connect: () => {
      },
      close: () => {
      }
    },
    transport: {
      stdin: () => {
      },
      stdout: () => {
      }
    },
    _initialized: false
  };
}
async function main() {
  const result = createServer();
  console.error("[flow-kit] MCP Server \u521D\u59CB\u5316\u5B8C\u6210");
  return result;
}
if (import_meta.url === `file://${process.argv[1]}`) {
  main();
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  createServer,
  main
});
