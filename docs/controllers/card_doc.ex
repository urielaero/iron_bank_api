defmodule IronBankDoc.Card do

  def index, do: %{
    description: "get all cards",
    summary: "Get all cards",
    tags: ["card"],
    parameters: [] 
  }

  def create, do:  %{
    description: "Create new Card",
    summary: "Create a new Card",
    tags: ["card"],
    parameters: [%{
      "name" => "token",
      "in" => "query",
      "description" => "Token authorization by /cards/login",
      "required" => true,
      "type" => "string"
    },%{
      "name" => "body",
      "in" => "body",
      "description" => "Information for card",
      "required" => true,
      "schema": %{"$ref": "#/definitions/IronCard.Card"}
    }] 
  }

  def show, do: %{
    description: "get card",
    summary: "Get card by id",
    tags: ["card"],
    parameters: [%{
      "name" => "id",
      "in" => "path",
      "description" => "Id of Card",
      "required" => true,
      "type" => "string"
    }] 
  }

  def update, do: %{
    description: "Update info by Id",
    summary: "Update Card info",
    tags: ["card"],
    parameters: [%{
      "name" => "token",
      "in" => "query",
      "description" => "Token authorization by /cards/login",
      "required" => false,
      "type" => "string"
    },
    %{
      "name" => "id",
      "in" => "path",
      "description" => "Id of card",
      "required" => true,
      "type" => "string"
    },
    %{
      "name" => "body",
      "in" => "body",
      "description" => "Fields to update",
      "type" => "string",
      "required" => true,
      "schema": %{"$ref": "#/definitions/IronBank.Card"}
    }] 
  
  }

end
