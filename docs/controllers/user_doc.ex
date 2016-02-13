defmodule IronBankDoc.User do

  def index, do: %{
    description: "get all users",
    summary: "Get all users",
    tags: ["user"],
    parameters: [] 
  }

  def create, do:  %{
    description: "Create new User",
    summary: "Create a new User",
    tags: ["user"],
    parameters: [%{
      "name" => "token",
      "in" => "query",
      "description" => "Token authorization by /users/login",
      "required" => false,
      "type" => "string"
    },%{
      "name" => "body",
      "in" => "body",
      "description" => "Information for user",
      "required" => true,
      "schema": %{"$ref": "#/definitions/IronBank.User"}
    }] 
  }

  def show, do: %{
    description: "get user",
    summary: "Get user by id",
    tags: ["user"],
    parameters: [%{
      "name" => "id",
      "in" => "path",
      "description" => "Id of User",
      "required" => true,
      "type" => "string"
    }] 
  }

  def update, do: %{
    description: "Update info by Id",
    summary: "Update User info",
    tags: ["user"],
    parameters: [%{
      "name" => "token",
      "in" => "query",
      "description" => "Token authorization by /users/login",
      "required" => false,
      "type" => "string"
    },
    %{
      "name" => "id",
      "in" => "path",
      "description" => "Id of user",
      "required" => true,
      "type" => "string"
    },
    %{
      "name" => "body",
      "in" => "body",
      "description" => "Fields to update",
      "type" => "string",
      "required" => true,
      "schema": %{"$ref": "#/definitions/IronBank.User"}
    }] 
  
  }

  def set_password, do: %{
    description: "set password for user Id",
    summary: "Update password for User",
    tags: ["user"],
    parameters: [%{
      "name" => "token",
      "in" => "query",
      "description" => "Token authorization by /users/login",
      "required" => false,
      "type" => "string"
    },
    %{
      "name" => "password",
      "in" => "query",
      "description" => "password of user",
      "required" => true,
      "type" => "string"
    }] 
  }

  def login, do: %{
    description: "check password for user Id",
    summary: "Check password for User",
    tags: ["user"],
    parameters: [%{
      "name" => "code",
      "in" => "query",
      "description" => "code/id of user",
      "required" => true,
      "type" => "string"
    },
    %{
      "name" => "password",
      "in" => "query",
      "description" => "password of user",
      "required" => true,
      "type" => "string"
    }] 
  }

end
