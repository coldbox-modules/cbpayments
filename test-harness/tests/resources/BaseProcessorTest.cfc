component extends="coldbox.system.testing.BaseTestCase" {

	property name="processor";

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		variables.model = getInstance( variables.processor );
	}

	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Stripe Processor", function(){
			it( "can be created", function(){
				expect( variables.model ).toBeComponent();
			} );


			it( "can give me its name and version", function(){
				var name    = variables.model.getName();
				var version = variables.model.getVersion();

				expect( name.len() ).toBeTrue();
				expect( version.len() ).toBeTrue();
			} );

			it( "can get the processor", function(){
				var processor = variables.model.getProcessor();
				expect( processor ).toBeComponent();
			} );

			it( "Will throw an error on a fake charge", function(){
				var response = variables.model.charge(
					amount      = 1,
					source      = "bogus",
					description = "Unit test charge"
				);

				expect( response.getError() ).toBeTrue();
				debug( response.getContent() );
			} );

			it( "can make a test valid charge", function(){
				var response = variables.model.charge(
					amount      = 100,
					source      = "tok_visa",
					description = "Unit test charge"
				);

				expect( response.getError() ).toBeFalse();
				expect( response.getContent().paid ).toBeTrue();
				expect( response.getContent() )
					.toBeStruct()
					.toHaveKey( "id" )
					.toHaveKey( "object" )
					.toHaveKey( "amount" )
					.toHaveKey( "amount_captured" )
					.toHaveKey( "amount_refunded" )
					.toHaveKey( "balance_transaction" )
					.toHaveKey( "billing_details" )
					.toHaveKey( "processor" )
					.toHaveKey( "captured" )
					.toHaveKey( "created" )
					.toHaveKey( "currency" )
					.toHaveKey( "disputed" )
					.toHaveKey( "fraud_details" )
					.toHaveKey( "livemode" )
					.toHaveKey( "metadata" )
					.toHaveKey( "outcome" )
					.toHaveKey( "paid" )
					.toHaveKey( "payment_method" )
					.toHaveKey( "payment_method_details" )
					.toHaveKey( "receipt_url" )
					.toHaveKey( "refunded" )
					.toHaveKey( "status" );
				variables.testCharge = response.getContent().id;
			} );

			it( "can make a test preAuth", function(){
				var response = variables.model.preAuthorize(
					amount      = 100,
					source      = "tok_visa",
					description = "Unit test charge"
				);

				expect( response.getError() ).toBeFalse();
				expect( response.getContent().paid ).toBeTrue();
				expect( response.getContent() )
					.toBeStruct()
					.toHaveKey( "id" )
					.toHaveKey( "object" )
					.toHaveKey( "amount" )
					.toHaveKey( "amount_captured" )
					.toHaveKey( "amount_refunded" )
					.toHaveKey( "billing_details" )
					.toHaveKey( "processor" )
					.toHaveKey( "captured" )
					.toHaveKey( "created" )
					.toHaveKey( "currency" )
					.toHaveKey( "disputed" )
					.toHaveKey( "fraud_details" )
					.toHaveKey( "livemode" )
					.toHaveKey( "metadata" )
					.toHaveKey( "outcome" )
					.toHaveKey( "paid" )
					.toHaveKey( "payment_method" )
					.toHaveKey( "payment_method_details" )
					.toHaveKey( "receipt_url" )
					.toHaveKey( "refunded" )
					.toHaveKey( "status" );
				expect( response.getContent().captured ).toBeFalse();
				expect( structKeyExists( response.getContent(), "balance_transaction" ) ).toBeFalse();
				variables.testPreAuth = response.getContent().id;
			} );

			it( "Can capture a pre-authorization", function(){
				if ( !variables.keyExists( "testPreAuth" ) ) {
					variables.testPreAuth = variables.model
						.preAuthorize(
							amount      = 100,
							source      = "tok_visa",
							description = "Unit test charge"
						)
						.getContent()
						.id;
				}
				var response = variables.model.capture( variables.testPreAuth );

				expect( response.getContent() )
					.toBeStruct()
					.toHaveKey( "id" )
					.toHaveKey( "object" )
					.toHaveKey( "amount" )
					.toHaveKey( "amount_captured" )
					.toHaveKey( "amount_refunded" )
					.toHaveKey( "balance_transaction" )
					.toHaveKey( "billing_details" )
					.toHaveKey( "processor" )
					.toHaveKey( "captured" )
					.toHaveKey( "created" )
					.toHaveKey( "currency" )
					.toHaveKey( "disputed" )
					.toHaveKey( "fraud_details" )
					.toHaveKey( "livemode" )
					.toHaveKey( "metadata" )
					.toHaveKey( "outcome" )
					.toHaveKey( "paid" )
					.toHaveKey( "payment_method" )
					.toHaveKey( "payment_method_details" )
					.toHaveKey( "receipt_url" )
					.toHaveKey( "refunded" )
					.toHaveKey( "status" );
			} );

			it( "Will error on a fake refund", function(){
				var response = variables.model.refund( charge = 123, reason = "Unit test refund" );
				expect( response.getError() ).toBeTrue();
			} );
		} );
	}

}

