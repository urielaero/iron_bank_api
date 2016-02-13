defmodule IronBankDoc.Bank do

  def index, do: %{
    description: "get all banks",
    summary: "Get all banks",
    tags: ["bank"],
    parameters: [] 
  }

  def create, do:  %{
    description: "Create new Bank",
    summary: "Create a new Bank",
    tags: ["bank"],
    parameters: [%{
      "name" => "token",
      "in" => "query",
      "description" => "Token authorization by /users/login",
      "required" => true,
      "type" => "string"
    },%{
      "name" => "body",
      "in" => "body",
      "description" => "Information for bank",
      "required" => true,
      "schema": %{"$ref": "#/definitions/IronBank.Bank"}
    }] 
  }

  def show, do: %{
    description: "get bank",
    summary: "Get bank by id",
    tags: ["bank"],
    parameters: [%{
      "name" => "id",
      "in" => "path",
      "description" => "Id of Bank",
      "required" => true,
      "type" => "string"
    }] 
  }

  def update, do: %{
    description: "Update info by Id",
    summary: "Update Bank info",
    tags: ["bank"],
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
      "description" => "Id of bank",
      "required" => true,
      "type" => "string"
    },
    %{
      "name" => "body",
      "in" => "body",
      "description" => "Fields to update",
      "type" => "string",
      "required" => true,
      "schema": %{"$ref": "#/definitions/IronBank.Bank"}
    }] 
  
  }

end
