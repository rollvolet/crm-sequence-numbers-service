import { query, sparqlEscapeUri, sparqlEscapeString, sparqlEscapeDateTime } from 'mu'
import { startOfYear as startOfYearFn } from 'date-fns/startOfYear'
import { addYears } from 'date-fns/addYears';
import { format } from 'date-fns/format';

export fetchNextSequenceNumber = (type, scope) ->
  if type is 'http://data.rollvolet.be/vocabularies/crm/Request'
    fetchNextInt type

  else if type is 'http://data.rollvolet.be/vocabularies/crm/Intervention'
    fetchNextInt type

  else if type is 'http://schema.org/Offer' # e.g. 34/01/14/02
    prefix = format(addYears(new Date(), 10), 'yy/MM/dd');
    filter = "FILTER(STRSTARTS(?number, #{sparqlEscapeString(prefix)}))"
    offerNumber = await fetchLatestNumber type, 'http://schema.org/identifier', filter
    if offerNumber
      sequenceNumber = parseInt(offerNumber.substr(offerNumber.lastIndexOf('/') + 1));
      postfix = "#{sequenceNumber + 1}".padStart(2, '0')
      "#{prefix}/#{postfix}"
    else
      "#{prefix}/01"

  else if type is 'https://purl.org/p2p-o/document#E-Invoice'
    startOfYear = startOfYearFn new Date()
    filter = """
      ?s <https://purl.org/p2p-o/invoice#dateOfIssue> ?date .
      FILTER (?date >= #{sparqlEscapeDateTime(startOfYear)})
    """
    # Value for first invoice of a new year. E.g. 340001
    initValue = (parseInt(format(startOfYear, 'yy')) + 10) * 10000 + 1
    fetchNextInt type, 'https://purl.org/p2p-o/invoice#invoiceNumber', filter, initValue

  else if type is 'http://www.w3.org/2006/vcard/ns#Vcard'
    fetchNextInt 'http://www.w3.org/2006/vcard/ns#VCard', 'http://www.w3.org/2006/vcard/ns#hasUID'

  else if type is 'http://www.semanticdesktop.org/ontologies/2007/03/22/nco#Contact'
    throw new Error("Scope is missing to determine next sequence for #{type}") unless scope
    filter = "#{sparqlEscapeUri(scope)} <http://www.semanticdesktop.org/ontologies/2007/03/22/nco#representative> ?s ."
    fetchNextInt type, 'http://schema.org/position', filter

  else if type is 'https://data.vlaanderen.be/ns/gebouw#Gebouw'
    throw new Error("Scope is missing to determine next sequence for #{type}") unless scope
    filter = "#{sparqlEscapeUri(scope)} <http://schema.org/affiliation> ?s ."
    fetchNextInt type, 'http://schema.org/position', filter

  else
    throw new Error("Unable to fetch next sequence number for unsupported type #{type}")

fetchNextInt = (type, predicate, where, initValue = 1) ->
  number = await fetchLatestNumber type, predicate, where
  if number then parseInt(number) + 1 else initValue

fetchLatestNumber = (type, predicate = 'http://schema.org/identifier', where = '') ->
  result = await query """
    SELECT ?number
    WHERE {
      ?s a #{sparqlEscapeUri(type)} ;
        #{sparqlEscapeUri(predicate)} ?number .
      #{where}
    } ORDER BY DESC(?number) OFFSET 0 LIMIT 1
  """
  result.results.bindings[0]?.number?.value
