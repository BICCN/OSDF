# Open Science Data Framework (OSDF) API
<a name="top"></a> 

***

## Contents

* [Authentication](#auth)
* [Server Information](#info)
* [Namespaces](#ns)
  * [List Available Namespaces](#namespace_list)
  * [Retrieve a Namespace](#namespace_retrieve)
* [Access Control Lists (ACLs)](#acl)
  * [List ACL Membership](#acl_membership_list)
  * [Create an ACL](#acl_create)
  * [Add an ACL Entry](#acl_entry_create)
  * [Remove an ACL Entry](#acl_entry_remove)
* [Nodes](#nodes)
  * [Create a Node](#node_create)
  * [Retrieve a Node](#node_retrieve)
  * [Retrieve Node Version/History](#node_version)
  * [Retrieve Nodes Linked To](#node_out)
  * [Retrieve Nodes Linked From](#node_in)
  * [Edit a Node](#node_edit)
  * [Delete a Node](#node_del)
* [Schemas](#schemas)
  * [List All Namespace Schemas](#schema_list)
  * [Retrieve a Schema](#schema_retrieve)
  * [Retrieve an Auxiliary Schema](#schema_aux_retrieve)
  * [Create a Schema]("#schema_create")
  * [Create an Auxiliary Schema]("#schema_aux_create)
* [Queries/Search](#queries)
  * [Query DSL Examples]("#query_dsl_examples")
  * [Filters]("#query_filters")
  * [Pagination]("#query_pag")


## <a name="auth"></a> Authentication

Authentication to an OSDF is managed with “Basic” HTTP authentication and each request must include the “Authorization” HTTP header. Use your assigned OSDF username and the API token as the password.

Username: jdoe
Password: p@ssw0rd

    $ curl -u jdoe:p@ssw0rd -X GET <OSDF_URL>/nodes/<NODE_ID>
    
For the remainder of this API documentation, the combination of the username and the password, will be referred to as "\<AUTH>" for brevity.

[top](#top)

***

## <a name="info"></a> Server Information

Basic information about the OSDF instance, such as a description, contact information, and the version of the API (which may change over time) may be retrieved with a simple HTTP GET request. The "title", "comment1" and "comment2" fields are limited to 128 characters, the "description" is limited to 512 characters. The email contact fields values must adhere to RFC 5322 and RFC 5321 but are further limited to a maximum of 128 characters.

**Request: GET /info**

A GET to the URL will an object.

Example Request:

    $ curl -u <AUTH> -X GET <OSDF_URL>/info

**Response: (application/json)**

Example Response:

	{

[top](#top)

## <a name="ns"></a> Namespaces

Each namespace associated with OSDF will have its own specific schemas that determine how a developers and users will interact with it. Namespaces will be globally unique. In other words, there cannot be a more than one namespace with a given name that would result in a namespace name collision. Namespace names beginning with the string "osdf" are reserved for internal system and implementation use and are prohibited from use by end users. Namespace names are limited to 32 characters and descriptions to 256 characters. For the namespace name, each character must be a member of the alphanumeric ASCII character set (A-Za-z0-9) or an underscore (_) or hyphen (-).

### <a name="namespace_list"></a> List Available Namespaces

**Request: GET /namespaces**

A GET to the URL will yield a JSON object with namespace names as keys.

Example Request:

    $ curl -u <AUTH> -X GET <OSDF_URL>/namespaces

### <a name="namespace_retrieve"></a> Retrieve a Namespace

**Request: GET /namespaces/${ns}**
    
A GET to the URL will yield specific namespace details.

Example Request:

    $ curl -u <AUTH> -X GET <OSDF_URL>/namespaces/<NS>

A JSON object with the details of the requested namespace.


[top](#top)

***

## <a name="acl"></a> Access Control Lists (ACLs)

Access Control Lists (ACLs) control which sets of users are allowed to read and write data from nodes as well as namespace. They can be thought of as "groups" in traditional operating system terminology. ACL names have the same restrictions that namespace names have: a maximum of 32 characters and using the ASCII alphanumeric character set (A-Za-z0-9) plus underscores (_) and hyphens (-). Additionally, the "all" value for ACL names is reserved and signifies global access across all users.

### <a name="acl_membership_list"></a> List ACL Membership

Users may retrieve a list of the ACLs they are members of. Users may belong to various ACLs in different namespaces, so the result set contains a list of ACLs for each namespace the user is a member of. Users do not have the ability to see what ACLs and namespaces other users are members of.

**Request: GET /acls**

Example Request:

    $ curl -u <AUTH> -X GET <OSDF_URL>/acls

**Response (application/json)**

A GET to the URL will yield information on ACL membership.

[top](#top)

### <a name="acl_create"></a> Create an ACL

Namespace administrators (anyone with write permission to a namespace) may need to create new ACLs to better manage the consumers of the data in the namespace. To create a new ACL, a JSON document must be posted to the an ACL related URL. The JSON document must contain the namescace name ans well as the ACL name. ACL names have the same restrictions as namespace names.

**Request: POST /acls/${ns}/**

A POST to the URL will create the ACL in the specified namespace.

Example:





    $ curl -u <AUTH> -X POST -d @new_acl.json <OSDF_URL>/acls/<NS>
    
where \<NS> is the name of the namespace, and new_acl.json is a file containing the JSON data for the ACL.
    
**Response:**

### Add an ACL Entry

TODO

### Remove an ACL Entry

TODO

[top](#top)

***

## <a name="nodes"></a> Nodes

An OSDF node is a generic data container. The specific mandatory attributes for an OSDF node are a namespace that defines the node's general project, a unique ID, the linkages (if any) describing relationships to other nodes, the node type, ACLs restricting for access control, and a generic “meta” key for arbitrary JSON data. The intent of the “meta” field is to hold the namespace specific node content (controlled by the namespace and in conjunction with the optional use of JSON schemas). In the “linkage” field, each node describes how it is connected to other nodes. Since there may be multiple connection types, there can be multiple links for each. Each linkage type has node members listed by node id.

[top](#top)

### <a name="node_create"></a> Create a Node

**Request: POST /nodes**

Abstract Form: 

Command line example (where data.json is a file containing the data):

    $ curl -u <AUTH> -X POST -d @data.json <OSDF_URL>/nodes

Returns HTTP 201 ("Created") on success. The HTTP Location header is set to the URL for the new node and the node’s ID can be extracted from the URL. Failed requests, an invalid "node_type", or ACL value, or a "meta" section that does not conform to the node type's registered JSON Schema, will yield HTTP 422 ("Unprocessable Entity"). Error details may be found in the X-OSDF-Error HTTP header. Other errors may result in HTTP 500 ("Server error") responses.

### <a name="node_retrieve"></a> Retrieve a Node

**Request: GET /nodes/${node_id}**

A GET to the URL will yield a JSON document describing the node.

Example Request:

    $ curl -u <AUTH> -X GET <OSDF_URL>/nodes/<NODE_ID>
    
where \<NODE_ID> is the ID of the node we wish to retrieve the data for.
    



[top](#top)

### <a name="node_version"></a> Retrieve Node Version/History

All Nodes are versioned so that an authorized user can always retrieve a previous version of a node and examine how a node has changed over time. This ensures that the combination of node ID and version is immutable and can be easily retrieved at any point in time unless the node itself is deleted.

**Request: GET /nodes/${node_id}/ver/${version_number}**

A GET to the URL will yield a document describing the previous node version.

**Response: (application/json)**

Example Response: 
                "write": [ "researchers" ]
              },


[top](#top)

### <a name="node_out"></a> Retrieve Nodes Linked To

To retrieve the nodes that a particular node links out to, via the "linkage" section of the node's JSON, one can simply parse the node IDs from the various arrays in the JSON object, or one can simply make a GET request to a URL to retrieve the nodes in one JSON data structure.

**Request: GET /nodes/${node_id}/out**

Example Request:


**Response: (application/json)**

Example data: 

### <a name="node_in"></a> Retrieve Nodes Linked From

To retrieve the nodes that point to a particular node (as a target), then simply make a GET request to the sepecial "in" URL that every node possesses.

**Request: GET /nodes/${node_id}/in**

Example Request:


**Response: (application/json)**

Example data: 

[top](#top)

### <a name="node_edit"></a> Edit a Node

Users may edit/update nodes with new data by using the HTTP PUT method. However, because of the nature of REST and HTTP, multiple simultaneous requests to update a node are possible. Therefore, for consistency, and to ensure that the correct version of a node is being operated on, requests to update a node must include the node's version. If a request for a node is received for an older version, that request will fail.

**Request: PUT /nodes/${node_id}**

A PUT to the URL with a JSON structure describing the new node data.
**Response:**

Returns HTTP status code 200 on success.

### <a name="node_del"></a> Delete a Node



[top](#top)

***

## <a name="schemas"></a> Schemas

Each namespace may have multiple schemas (expressed with the [JSON Schema](http://json-schema.org) standard) to control the structure of nodes and to provide validation. A schema is itself a JSON document that defines how other JSON documents must be formatted.




A GET to the URL will retrieve a collection of all the schemas belonging to the specified namespace.

**Response: (application/json)**

Example Response: 





A GET to the URL will retrieve the specified [JSON Schema](http://json-schema.org) document.

**Response: (application/json)**

Example Response: 



A POST to the URL with a properly formed query will return the search results within the specified namespace.



**Response:**

If the JSON Schema was properly registered into the namespace, an HTTP Status code of 200 will be returned. However, if the document was malformed or if it contained invalid JSON Schema data, then an HTTP 422 error will be returned. Other errors may result in an HTTP 500 error. Error details may be contained in the X-OSDF-Error HTTP response header.

### <A NAME="schema_aux_create"></a> Create an Auxiliary Schema

TBD

[top](#top)


## <a name="queries"></a> Queries/Search

Queries for nodes may be performed by posting a JSON document to namespace specific URL. The query JSON documents use the “Elasticsearch Query DSL” to formulate the search criteria and each search request is limited to a single namespace. The [Elasticsearch DSL](http://www.elasticsearch.org/guide/reference/query-dsl/) provides a robust mechanism for formulating complicated queries in which terms can be logically combined, filtered; marked as must include, should include, or must not include; as well as many other search options.

### <a name="query_create"></a> Query Nodes

**Request: POST /nodes/query/${ns}**

A POST to the URL with a properly formed query will return the search results within the specified namespace.
      <OSDF_URL>/nodes/query/<NS>
    



**Response: (application/json)**

Example Response: 
           <RESULT_JSON_DOC_2>,
           <RESULT_JSON_DOC_N>

[top](#top)

### <a name="query_dsl_examples"></a> Query DSL Examples

Presented here, for convenience, are a few examples of common queries. The full query DSL can be found [here](http://www.elasticsearch.org/guide/reference/query-dsl/).

#### Simple Term Query

This query will return all documents containing the top-level term “node_type” with the value “sample”.  If searching for a nested field, use the dot operator.

[top](#top)

#### Simple Value Query

This query will return all documents containing the literal “sample” string on any part of the document’s JSON structure.


Nested JSON fields can be specified using the dot operator. The query below will only return documents with a matching hierarchical JSON structure.

    {
    }

[top](#top)



[top](#top)

                 {
                     "term" : { "node_type" : "sample" }
                 }
                 {
                     "term" : { "visit_number" : 1 }
                 }


### <a name="query_filters"></a> Filters

In addition to queries, filters may be used to further limit the query results. For example, the following boolean query has been filtered to only return samples with a collection date of "2012-01-01". Filters have both "query" and "filter" sections, therefore, filtered queries can actually be nested.
			                {
			                    "term" : { "node_type" : "sample" }
			                }
			                {
			                    "term" : { "visit_number" : 1 }
			                }
[top](#top)

### <a name="query_pag"></a> Pagination

Query results are paginated if the results are too large. The number of results returned for each page is specified by the implementation. Rather than making a query and using the X-OSDF-Query-ResultSet header to retrieve the next page, an OSDF user may elect to request a specific page or result range. Retrieving a specific page returns the same results as a regular query, but allows the user to better control which results are returned.

[top](#top)