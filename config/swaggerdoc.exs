use Mix.Config

config :swaggerdoc,
  swagger_version: "2.0",
  project_version: "0.0.1",
  project_name: "Iron bank api",
  project_desc: "The REST API for the Iron Bank of Braavos",
  project_terms: "https://www.mozilla.org/en-US/MPL/2.0/",
  project_contact_name: "Braavos Api Team",
  project_contact_email: "api@braavos.com",
  project_contact_url: "http://api.braavos.com",
  base_path: "/",
  pipe_through: [:api],
  consumes: ["application/json"],
  produces: ["application/json"]  
