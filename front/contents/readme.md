---
---

# Schematic Ipsum

Schematic Ipsum is a simple service that generates fake JSON data in accordance with a [JSON Schema](http://json-schema.org). By making requests to a simple API, you can generate rich structured data with appropriately typed content, as opposed to your average plain text lorem ipsum.

Inspired by [Sacha Greif](http://sachagreif.com/why-lorem-ipsum-is-hurting-your-designs/) and sites like [Space Ipsum](http://spaceipsum.com) and [Fillerati](http://fillerati.com), Schematic Ipsum doesn't generate traditional Latin text. Instead, it pulls names, titles, and text from featured articles on Wikipedia in order to generate *realistic* data.

## An Example

Say we wanted to model users with JSON objects like this one:

```json
{
  "id": "1a8b8863-a859-4d68-b63a-c466e554fd13",
  "name": "Ada Lovelace",
  "email": "ada@geemail.com",
  "bio": "First programmer. No big deal.",
  "age": 198
}
```

A JSON schema for this object might look like this:

```json
{
  "type": "object",
  "properties": {
    "id": { "type": "string" },
    "name": { "type": "string" },
    "email": { "type": "string", "format": "email" },
    "bio": { "type": "string" },
    "age": { "type": "integer" }
  }
}
```

Now we can just send that schema off to Schematic Ipsum using a simple HTTP
POST request and get back a new user object.

**Request:**

```
POST http://schematic-ipsum.herokuapp.com/ HTTP/1.1
Content-Type: application/json
```
```json
{
  "type": "object",
  "properties": {
    "id": { "type": "string" },
    "name": { "type": "string" },
    "email": { "type": "string", "format": "email" },
    "bio": { "type": "string" },
    "age": { "type": "integer" }
  }
}
```

**Response body:**
```json
{
  "id": "It has been suggested that he adopted Christianity as part of a settlement with Oswiu.",
  "name": "Its upperparts and sides are grey, but elongated grey feathers with black central stripes are draped across the back from the shoulder area.",
  "email": "rita_sakellariou@vancouver.edu",
  "bio": "Wintjiya came from an area north-west or north-east of Walungurru (the Pintupi-language name for Kintore, Northern Territory).",
  "age": 39
}
```

Hmm, well that doesn't look quite like our first user object. It matches the schema -- all the properties have the right type -- but the schema didn't include enough information to produce realistic strings.

To solve this problem, Schematic Ipsum lets you add hints in your schema to specify the kinds of strings you want. Here's the same schema with hints:

**Request:**
```
POST http://schematic-ipsum.herokuapp.com/ HTTP/1.1
Content-Type: application/json
```
```json
{
  "type": "object",
  "properties": {
    "id": { "type": "string", "ipsum": "id" },
    "name": { "type": "string", "ipsum": "name" },
    "email": { "type": "string", "format": "email" },
    "bio": { "type": "string", "ipsum": "sentence" },
    "age": { "type": "integer" }
  }
}
```

**Response body:**
```json
{
  "id": "9f7c0eff-c217-4602-9ef1-489aaed341f4",
  "name": "Jonty Rhodes",
  "email": "john_laroche@troop.net",
  "bio": "Multiple copies were made of that original which were distributed to monasteries across England, where they were independently updated.",
  "age": 51
}
```

Much better! With just a few simple additions, we've got much more realistic (if slightly whimsical) data. The full specification for hints is described in the API section below.

## Generating Multiple Objects

If you don't feel like sending a POST request for every object you want to generate, you can simply specify how many objects you want using the `n` query parameter at the end of the url. For example, if we wanted to generate 10 integers, we could do this:

**Request:**
```
POST http://schematic-ipsum.herokuapp.com/?n=10 HTTP/1.1
Content-Type: application/json
```
```json
{ "type": "integer" }
```

**Response body:**
```json
[ 8, 48, 35, 84, 73, -27, 45, -38, -12, 21 ]
```

## Creating Schemas

If creating a schema by hand seems too tedious -- if it seems like a
mechanical, algorithmic process -- you can visit <http://www.jsonschema.net>
and automagically generate a schema for a JSON object.

## API

Schematic Ipsum's API is fairly simple -- it consists of a single operation:

**URL**: `http://schematic-ipsum.herokuapp.com/`

**Method**: `POST`

**Body**: A valid JSON Schema (according to the [v3 spec](http://tools.ietf.org/html/draft-zyp-json-schema-03)), optionally embellished with `"ipsum"` hints.

**Query parameters**:

- `n` - optional - positive integer

    How many JSON objects to generate (default 1). Currently limited to 50 at
    most.

### Schema Properties

Schematic Ipsum doesn't yet support the full JSON Schema spec. These are the currently supported properties:

#### `"type"`

- <span class="api-str">`"number"`</span>

    Any number, including negatives and floating points.

    ```javascript
    { "type": "number" } ==> -33.333
    ```

- <span class="api-str">`"integer"`</span>

    Just integers, not including floating points.

    ```javascript
    { "type": "integer" } ==> 42
    ```

- <span class="api-str">`"boolean"`</span>

    `true` or `false`

    ```javascript
    { "type": "boolean" } ==> true
    ```

- <span class="api-str">`"object"`</span>

    The `"object"` type allows for nested schemas. When using this type, the schema must also have a `"properties"` property whose value is an object where the keys are the names of the properties and the values are schemas.

    ```javascript
    {
      "type": "object",
      "properties": {
        "count": { "type": "integer" }
      }
    }
    ==> { "count": 100 }
    ```

- <span class="api-str">`"array"`</span>

    Arrays are another way to produce nested data. When using type `"array"`, the schema must also have a `"items"` property whose value is a schema for the elements of the array.

    ```javascript
    {
      "type": "array",
      "items": { "type": "boolean" }
    }
    ==> [true, false, false, false, true]
    ```

- <span class="api-str">`"string"`</span>

    At its most basic, the `"string"` type will just generate a string.

    ```javascript
    { "type": "string" } ==> "What a boring schema"
    ```

#### `"format"`

Schemas with type `"string"` may also have a property `"format"` whose value is a string. Using the `"format"` property will generate a string of that format as described in the JSON Schema spec ([section 5.23](http://tools.ietf.org/html/draft-zyp-json-schema-03#section-5.23)). The following formats are currently supported:

  - <span class="api-str">`"date-time"`</span> - `"1977-09-30T12:25:29.729Z"`

  - <span class="api-str">`"color"`</span> - `"#77700b"`

  - <span class="api-str">`"phone"`</span> - `"(646) 424 1532"`

  - <span class="api-str">`"uri"`</span> - `"http://average.wentja.edu"`

    Not guaranteed to point to a working website

  - <span class="api-str">`"email"`</span> - `"rayner_heppenstall@and.xxx"`

    Guaranteed to not point to a working email


#### `"ipsum"`

String schemas may optionally have a hint, which is specified with the `"ipsum"` property, whose value must be a string. The following hints are currently supported:

  - <span class="api-str">`"id"`</span> - `"1a8b8863-a859-4d68-b63a-c466e554fd13"`

    An RFC4122 v4 UUID (basically 16 random characters with some dashes). You can pretty much rely on these being unique in any set of data you generate.

  - <span class="api-str">`"name"`</span> - `"Vincent van Gogh"`

  - <span class="api-str">`"first name"`</span> - `"Vincent"`

  - <span class="api-str">`"last name"`</span> - `"van Gogh"`

  - <span class="api-str">`"title"`</span> - `"Octopus wrestling"`

    The title of a random Wikipedia article.

  - <span class="api-str">`"word"`</span> - `"half-baked"`

  - <span class="api-str">`"sentence"`</span> - `"Octopus wrestling -- now there's a half-baked idea!"`

  - <span class="api-str">`"paragraph"`</span>

    `"Well actually, octopus wrestling was most popular on the West Coast of the United States during the 1960s. At that time, annual World Octopus Wrestling Championships were held in Puget Sound, Washington."`
    ...you get the idea.

  - <span class="api-str">`"long"`</span> - multiple paragraphs

## Bugs

Please report bugs and feature requests on the [issues page](http://github.com/jonahkagan/schematic-ipsum/issues). Pull requests are welcome!

## About

Created by [Jonah Kagan](http://jonahkagan.me) using CoffeeScript, Node.js, and many helpful libraries from the community. Source is open at <http://github.com/jonahkagan/schematic-ipsum>. Hosted on Heroku.
