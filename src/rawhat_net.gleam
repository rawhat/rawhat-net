import gleam/bit_builder.{BitBuilder}
import gleam/bit_string
import gleam/erlang/file
import gleam/http/elli
import gleam/http.{Get}
import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/function
import gleam/io
import gleam/json
import gleam/list
import gleam/map.{Map}
import gleam/result
import gleam/string

pub external fn get_cwd() -> Result(String, Nil) =
  "file" "get_cwd"

pub external fn file_extension(file: String) -> String =
  "filename" "extension"

pub type AppError {
  NotFound(path: String)
}

pub type AppRequest(services) {
  AppRequest(
    body: String,
    headers: List(#(String, String)),
    method: http.Method,
    path: List(String),
    query: Map(String, String),
    config: Config,
    services: services,
  )
}

fn tuples_to_string(tuple: List(#(String, String))) -> String {
  case tuple {
    [] -> "\"\""
    values ->
      values
      |> list.map(fn(tup) {
        let #(key, value) = tup
        string.concat(["[\"", key, "\", \"", value, "\"]"])
      })
      |> string.join(", ")
  }
}

pub fn log_request(req: AppRequest(services)) -> Nil {
  [
    #("body", string.concat(["\"", req.body, "\""])),
    #("headers", tuples_to_string(req.headers)),
    #("method", string.concat(["\"", http.method_to_string(req.method), "\""])),
    #(
      "path",
      req.path
      |> join_path
      |> fn(p) { [p] }
      |> list.append(["\""], _)
      |> list.append(["\""])
      |> string.concat,
    ),
    #(
      "query",
      req.query
      |> map.to_list
      |> tuples_to_string,
    ),
  ]
  |> map.from_list
  |> map.fold(
    "",
    fn(str, key, value) {
      string.concat([str, "\n(\"", key, "\", ", value, ")"])
    },
  )
  |> io.println
}

pub type AppResult =
  Result(Response(BitBuilder), AppError)

fn ok_with(body: BitBuilder) -> AppResult {
  Ok(Response(body, status: 200, headers: []))
}

fn join_path(path: List(String)) -> String {
  string.join(path, "/")
}

fn not_found(path: List(String)) -> AppResult {
  Error(NotFound(path: string.join(path, "/")))
}

fn body_of_type(body: BitString, content_type: String) -> AppResult {
  response.new(200)
  |> response.prepend_header("Content-Type", content_type)
  |> response.set_body(bit_builder.from_bit_string(body))
  |> Ok
}

// No funny business
fn validate_path(path: List(String)) -> Result(Nil, Nil) {
  case path {
    [] -> Ok(Nil)
    ["..", ..] -> Error(Nil)
    [_, ..rest] -> validate_path(rest)
  }
}

fn ext_to_content_type(ext: String) -> String {
  case ext {
    "" -> "application/x-binary"
    ".gleam" -> "application/gleam"
    ".js" -> "application/javascript"
    ".css" -> "application/stylesheet"
    ".html" -> "text/html"
    _ -> "text/plain"
  }
}

pub fn serve_file(path: List(String), root: String) -> AppResult {
  try _ =
    path
    |> validate_path
    |> result.replace_error(NotFound(join_path(path)))

  let joined = case path {
    [] | ["/"] -> join_path([root, "index.html"])
    _ -> join_path([root, ..path])
  }

  try contents =
    joined
    |> file.read_bits
    |> result.replace_error(NotFound(joined))

  let last = case list.last(path) {
    Error(_) -> "index.html"
    Ok(last) -> last
  }

  last
  |> file_extension
  |> ext_to_content_type
  |> body_of_type(contents, _)
}

pub fn router(request: AppRequest(services)) -> AppResult {
  log_request(request)
  case #(request.method, request.path) {
    #(Get, ["/"]) -> ok_with(bit_builder.from_string("Hello, world!"))
    #(Get, path) -> serve_file(path, request.config.static_root)
    #(_, path) -> not_found(path)
  }
}

pub type Config {
  Config(static_root: String)
}

pub type Services =
  Nil

pub fn parse_config(_path: string) -> Result(Config, String) {
  try cwd =
    get_cwd()
    |> result.replace_error("Failed to get cwd")
  Ok(Config(static_root: string.concat([cwd, "/priv"])))
}

pub fn make_service(
  config: Config,
) -> fn(Request(BitString)) -> AppRequest(Services) {
  fn(req: Request(BitString)) -> AppRequest(Services) {
    AppRequest(
      body: req.body
      |> bit_string.to_string
      |> result.unwrap(""),
      headers: req.headers,
      method: req.method,
      path: request.path_segments(req),
      query: req
      |> request.get_query
      |> result.map(map.from_list)
      |> result.unwrap(map.new()),
      config: config,
      services: Nil,
    )
  }
}

pub fn result_to_response(response: AppResult) -> Response(BitBuilder) {
  case response {
    Ok(resp) -> resp
    Error(NotFound(path)) ->
      [#("error", json.string(string.concat(["Not found: ", path])))]
      |> json.object
      |> json.to_string_builder
      |> bit_builder.from_string_builder
      |> Response(status: 404, headers: [], body: _)
  }
}

//                 make_service    Service  result_to_response
// Request(BitString) -> AppRequest -> AppResult -> Response(BitBuilder)
pub fn main() {
  try config = parse_config("")

  config
  |> make_service
  |> function.compose(router)
  |> function.compose(result_to_response)
  |> elli.become(on_port: 8080)
  |> result.replace_error("Failed to start server")
}
