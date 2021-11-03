public class SalesCreditMemo {

	public String odata_context {get;set;} // in json: @odata.context
	public List<Value> value {get;set;} 

	public SalesCreditMemo(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == '@odata.context') {
						odata_context = parser.getText();
					} else if (text == 'value') {
						value = arrayOfValue(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'SalesCreditMemo consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Value {
		public String odata_etag {get;set;} // in json: @odata.etag
		public String id {get;set;} 
		public String number_Z {get;set;} // in json: number
		public String externalDocumentNumber {get;set;} 
		public String creditMemoDate {get;set;} 
		public Date postingDate {get;set;} 
		public Date dueDate {get;set;} 
		public String customerId {get;set;} 
		public String customerNumber {get;set;} 
		public String customerName {get;set;} 
		public String billToName {get;set;} 
		public String billToCustomerId {get;set;} 
		public String billToCustomerNumber {get;set;} 
		public String sellToAddressLine1 {get;set;} 
		public String sellToAddressLine2 {get;set;} 
		public String sellToCity {get;set;} 
		public String sellToCountry {get;set;} 
		public String sellToState {get;set;} 
		public String sellToPostCode {get;set;} 
		public String billToAddressLine1 {get;set;} 
		public String billToAddressLine2 {get;set;} 
		public String billToCity {get;set;} 
		public String billToCountry {get;set;} 
		public String billToState {get;set;} 
		public String billToPostCode {get;set;} 
		public String currencyId {get;set;} 
		public String currencyCode {get;set;} 
		public String paymentTermsId {get;set;} 
		public String shipmentMethodId {get;set;} 
		public String salesperson {get;set;} 
		public Boolean pricesIncludeTax {get;set;} 
		public double discountAmount {get;set;} 
		public Boolean discountAppliedBeforeTax {get;set;} 
		public Double totalAmountExcludingTax {get;set;} 
		public Double totalTaxAmount {get;set;} 
		public Double totalAmountIncludingTax {get;set;} 
		public String status {get;set;} 
		public DateTime lastModifiedDateTime {get;set;} 
		public String invoiceId {get;set;} 
		public String invoiceNumber {get;set;} 
		public String phoneNumber {get;set;} 
		public String email {get;set;} 
		public String customerReturnReasonId {get;set;} 

		public Value(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == '@odata.etag') {
							odata_etag = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'number') {
							number_Z = parser.getText();
						} else if (text == 'externalDocumentNumber') {
							externalDocumentNumber = parser.getText();
						} else if (text == 'creditMemoDate') {
							creditMemoDate = parser.getText();
						} else if (text == 'postingDate') {
							postingDate = parser.getDateValue();
						} else if (text == 'dueDate') {
							dueDate = parser.getDateValue();
						} else if (text == 'customerId') {
							customerId = parser.getText();
						} else if (text == 'customerNumber') {
							customerNumber = parser.getText();
						} else if (text == 'customerName') {
							customerName = parser.getText();
						} else if (text == 'billToName') {
							billToName = parser.getText();
						} else if (text == 'billToCustomerId') {
							billToCustomerId = parser.getText();
						} else if (text == 'billToCustomerNumber') {
							billToCustomerNumber = parser.getText();
						} else if (text == 'sellToAddressLine1') {
							sellToAddressLine1 = parser.getText();
						} else if (text == 'sellToAddressLine2') {
							sellToAddressLine2 = parser.getText();
						} else if (text == 'sellToCity') {
							sellToCity = parser.getText();
						} else if (text == 'sellToCountry') {
							sellToCountry = parser.getText();
						} else if (text == 'sellToState') {
							sellToState = parser.getText();
						} else if (text == 'sellToPostCode') {
							sellToPostCode = parser.getText();
						} else if (text == 'billToAddressLine1') {
							billToAddressLine1 = parser.getText();
						} else if (text == 'billToAddressLine2') {
							billToAddressLine2 = parser.getText();
						} else if (text == 'billToCity') {
							billToCity = parser.getText();
						} else if (text == 'billToCountry') {
							billToCountry = parser.getText();
						} else if (text == 'billToState') {
							billToState = parser.getText();
						} else if (text == 'billToPostCode') {
							billToPostCode = parser.getText();
						} else if (text == 'currencyId') {
							currencyId = parser.getText();
						} else if (text == 'currencyCode') {
							currencyCode = parser.getText();
						} else if (text == 'paymentTermsId') {
							paymentTermsId = parser.getText();
						} else if (text == 'shipmentMethodId') {
							shipmentMethodId = parser.getText();
						} else if (text == 'salesperson') {
							salesperson = parser.getText();
						} else if (text == 'pricesIncludeTax') {
							pricesIncludeTax = parser.getBooleanValue();
						} else if (text == 'discountAmount') {
							discountAmount = parser.getIntegerValue();
						} else if (text == 'discountAppliedBeforeTax') {
							discountAppliedBeforeTax = parser.getBooleanValue();
						} else if (text == 'totalAmountExcludingTax') {
							totalAmountExcludingTax = parser.getIntegerValue();
						} else if (text == 'totalTaxAmount') {
							totalTaxAmount = parser.getDoubleValue();
						} else if (text == 'totalAmountIncludingTax') {
							totalAmountIncludingTax = parser.getDoubleValue();
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'lastModifiedDateTime') {
							lastModifiedDateTime = parser.getDateTimeValue();
						} else if (text == 'invoiceId') {
							invoiceId = parser.getText();
						} else if (text == 'invoiceNumber') {
							invoiceNumber = parser.getText();
						} else if (text == 'phoneNumber') {
							phoneNumber = parser.getText();
						} else if (text == 'email') {
							email = parser.getText();
						} else if (text == 'customerReturnReasonId') {
							customerReturnReasonId = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Value consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static SalesCreditMemo parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new SalesCreditMemo(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	




    private static List<Value> arrayOfValue(System.JSONParser p) {
        List<Value> res = new List<Value>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Value(p));
        }
        return res;
    }





}