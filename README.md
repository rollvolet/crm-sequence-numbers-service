# CRM sequence number service
Microservice generating sequence numbers for CRM resources

## Getting started
### Adding the service to your stack
Add the following snippet to your `docker-compose.yml` to include the sequence numbers service in your project.

```yml
sequence-numbers:
  image: rollvolet/crm-sequence-numbers-service
```

## Reference
### API
#### POST /sequence-numbers
Fetch the next sequence number for a resource of a given type.

##### Request
The request body contains the resource type for which a next sequence number must be generated and optionally some additional scope.

Possible values for `resource-type` are:
- `http://data.rollvolet.be/vocabularies/crm/Request`
- `http://data.rollvolet.be/vocabularies/crm/Intervention`
- `http://schema.org/Offer`
- `https://purl.org/p2p-o/document#E-Invoice`
- `http://www.w3.org/2006/vcard/ns#Vcard`
- `http://www.semanticdesktop.org/ontologies/2007/03/22/nco#Contact`
- `https://data.vlaanderen.be/ns/gebouw#Gebouw`


```json
{
  "data": {
    "type": "sequence-numbers",
    "attributes": {
      "resource-type": "http://www.semanticdesktop.org/ontologies/2007/03/22/nco#Contact",
      "scope": "http://data.rollvolet.be/customers/d01a9a2b-ace9-443e-8dab-cebcb81ec294"
    }
  }
}
```

##### Response
- `201 Created` with the generated number in the `number` attribute of the JSON response
- `400 Bad Request` if `resource-type` (or in some cases `scope`) is missing in the request body


