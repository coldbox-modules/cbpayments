/**
 * A cool processor/Stripe entity
 */
component
	extends   ="BaseProcessor"
	delegates ="DateTime@coreDelegates"
	implements="IPaymentProcessor"
	singleton
{

	// DI
	property name="stripe" inject="stripe@stripecfml";

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	 * Retrieve a human readable name for the processor
	 */
	function getName(){
		return "Stripe CFML";
	}

	/**
	 * If there is a version attached to the processor then return it here.
	 */
	function getVersion(){
		return "1.x.x";
	}

	/**
	 * Get the payment processor SDK library implementation.  This will be getting the raw processor.
	 */
	any function getProcessor(){
		return variables.stripe;
	}

	/**
	 * Pre-authorizes a transaction on the processor without capture
	 *
	 * @amount      The amount in cents to charge, example: $20 = 2000, $20.5 = 2050, it is required
	 * @source      A payment source to be charged, usually this is a card token, a customer token, etc. It is required
	 * @currency    Usually the three-letter ISO Currency code (Optional)
	 * @customerId  A customer identifier to attach to the charge (Optional)
	 * @description The description of the charge (Optional)
	 * @headers     A struct of headers to send with the processor (Optional)
	 * @metadata    A struct of metadata to send to the processor (Optional)
	 *
	 * @return a struct containing the error and, if no error, the content of the [charge object](https://stripe.com/docs/api/charges/object)
	 */
	ProcessorResponse function preAuthorize(
		required numeric amount,
		required source,
		currency = "usd",
		customerId,
		description     = "",
		struct metadata = {}
	){
		arguments.capture = false;
		return charge( argumentCollection = arguments );
	}

	/**
	 * Captures a charge created via pre-authorization
	 *
	 * @chargeId
	 *
	 * @return a struct containing the error and, if no error, the content of the [charge object](https://stripe.com/docs/api/charges/object)
	 */
	ProcessorResponse function capture( required chargeId ){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe capture starting: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.charges.capture( charge_id = arguments.chargeId );

		// Capture it baby!
		oResponse.setContent( formatChargeResponse( processorResponse.content ) );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe capture response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Make a charge on the processor
	 *
	 * @amount      The amount in cents to charge, example: $20 = 2000, $20.5 = 2050, it is required
	 * @source      A payment source to be charged, usually this is a card token, a customer token, etc. It is required
	 * @currency    Usually the three-letter ISO Currency code (Optional)
	 * @customerId  A customer identifier to attach to the charge (Optional)
	 * @description The description of the charge (Optional)
	 * @headers     A struct of headers to send with the processor (Optional)
	 * @metadata    A struct of metadata to send to the processor (Optional)
	 *
	 * @return a struct containing the error and, if no error, the content of the [charge object](https://stripe.com/docs/api/charges/object)
	 */
	ProcessorResponse function charge(
		required numeric amount,
		required source,
		currency = "usd",
		customerId,
		description     = "",
		boolean capture = true,
		struct metadata = {}
	){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe charge starting: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.charges.create( argumentCollection = arguments );
		// Charge it baby!
		oResponse.setContent( formatChargeResponse( processorResponse.content ) );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe charge response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Make a refund on the processor
	 *
	 * @charge   The identifier of the charge to refund.
	 * @amount   The amount in cents to refund, if not sent then the entire charge is refunded (Optional)
	 * @reason   A reason of why the refund (Optional)
	 * @headers  A struct of headers to send with the processor (Optional)
	 * @metadata A struct of metadata to send to the processor (Optional)
	 *
	 * @return a struct containing the error and, if no error, the content of the [refund object](https://stripe.com/docs/api/refunds/object)
	 */
	ProcessorResponse function refund(
		required charge,
		numeric amount,
		reason          = "",
		struct metadata = {}
	){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe refund starting: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.refunds.create( argumentCollection = arguments );

		// Charge it baby!
		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe refund response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Create a customer on Stripe so we can associate to a plan subscription
	 *
	 * @email         email of the customer we are creating
	 * @paymentMethod Token provided by the stripe form with the payment method
	 * @description   Customer description, very handy info that could be found in the provider
	 * @metadata      A struct of metadata to send to the processor (Optional)
	 *
	 * @return a struct containing the error and, if no error, the content of the [customer object](https://docs.stripe.com/api/customers/object)
	 */
	ProcessorResponse function createCustomer(
		required email,
		required paymentMethodId,
		description     = "",
		struct metadata = {}
	){
		var invoiceSettings = { "default_payment_method" : arguments.paymentMethodId };

		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe customer creation starting: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.customers.create(
			email            = arguments.email,
			payment_method   = arguments.paymentMethodId,
			description      = arguments.description,
			invoice_settings = invoiceSettings
		);

		// Create customer
		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe customer creation response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Retrieves a list of customers in the stripe system
	 *
	 * @limit    The max rows to return
	 * @offset   The offset to start the list
	 * @metadata
	 *
	 * @return a struct containing the error and, if no error, the content of the [customers list](https://docs.stripe.com/api/customers/list)
	 */
	ProcessorResponse function listCustomers(
		numeric limit   = 10,
		numeric offset  = 0,
		struct metadata = {}
	){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe list customers starting: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.customers.list(
			limit  = arguments.limit,
			offset = arguments.offset
		);

		// List customers
		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe list customers response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Get the customer struct from the provider
	 *
	 * @providerCustomerId The provider customer Id
	 * @metadata           A struct of metadata to send to the processor (Optional)* @return a struct containing the error and, if no error, the content of the [customer object](https://docs.stripe.com/api/customers/object)
	 */
	ProcessorResponse function getCustomer( required providerCustomerId, struct metadata ){
		var customer  = {};
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe get customer starting: #serializeJSON( arguments )#" );
		}

		oResponse.setContent( {} );

		// Find customer
		var customer = variables.stripe.customers.retrieve( arguments.providerCustomerId );
		if ( structKeyExists( customer, "content" ) && !structKeyExists( customer.content, "error" ) ) {
			oResponse.setContent( customer.content );
		} else {
			oResponse.setError( true );
			return oResponse;
		}

		// Check for additional errors
		if ( customer.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe get customer response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}


	/**
	 * Make a charge on the processor
	 * TODO: Add this to the interface
	 *
	 * @amount      The amount in cents to charge, example: $20 = 2000, $20.5 = 2050, it is required
	 * @currency    Usually the three-letter ISO Currency code (Optional)
	 * @customerId  A customer identifier to attach to the charge (Optional)
	 * @description The description of the charge (Optional)
	 */
	ProcessorResponse function createSetupIntent(
		required string customer,
		string description     = "",
		string currency        = "usd",
		string usage           = "off_session",
		boolean attach_to_self = false,
		string flow_directions = "inbound",
		struct metadata        = {}
	){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe setup intent creation request: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.setupIntents.create( argumentCollection = arguments );

		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe setup intent creation response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	ProcessorResponse function getSetupIntent( required intentId ){
	}

	/**
	 * Make a charge on the processor
	 * TODO: Add this to the interface
	 *
	 * @amount      The amount in cents to charge, example: $20 = 2000, $20.5 = 2050, it is required
	 * @currency    Usually the three-letter ISO Currency code (Optional)
	 * @customerId  A customer identifier to attach to the charge (Optional)
	 * @description The description of the charge (Optional)
	 */
	ProcessorResponse function createPaymentIntent(
		required numeric amount,
		required string customer,
		required string payment_method,
		string description = "",
		string currency    = "usd",
		struct metadata    = {}
	){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe payment intent creation request: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.paymentIntents.create( argumentCollection = arguments );

		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe payment intent creation response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}



	/**
	 * Retrieve the payment intent status
	 *
	 * @providerCustomerId
	 * @planId            
	 * @quantity          
	 * @metadata          
	 */
	public string function fetchPaymentIntentStatus( required string paymentIntentId ){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe payment intent status request: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.paymentIntents.retrieve( arguments.paymentIntentId );

		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe payment intent status response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}


	/**
	 * Create a subscription, combine a plan with a customer
	 *
	 * @plan     Plan to associate to the subscription
	 * @customer Customer to associate the subscription plan with
	 * @metadata A struct of metadata to send to the processor (Optional)
	 *
	 * @return a struct containing the error and, if no error, the content of the [subscription object](https://stripe.com/docs/api/subscriptions/object)
	 */
	ProcessorResponse function createSubscription(
		required providerCustomerId,
		required planId,
		numeric quantity = 1,
		struct metadata  = {}
	){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe subscription creation starting: #serializeJSON( arguments )#" );
		}

		var processorResponse = variables.stripe.subscriptions.create(
			customer = arguments.providerCustomerId,
			items    = [
				{
					"plan"     : arguments.planId,
					"quantity" : arguments.quantity
				}
			],
			expand = [ "latest_invoice.payment_intent" ]
		);
		// Create customer
		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe subscription creation response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Cancel a subscription in the provider.
	 * Cancelling a subscription retains access through the end of the billing period.
	 *
	 * @subscriptionId Subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 *
	 * @return a struct containing the error and, if no error, the content of the cancelled [subscription object](https://stripe.com/docs/api/subscriptions/object)
	 */
	ProcessorResponse function cancelSubscription( required subscriptionId, struct metadata = {} ){
		var oResponse = newResponse();

		var processorResponse = variables.stripe.subscriptions.update(
			arguments.subscriptionId,
			{ cancel_at_period_end : true }
		);
		// Associate payment method as default
		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		return oResponse;
	}

	/**
	 * Resume a subscription in the provider.
	 *
	 * @subscriptionId Subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 *
	 * @return a struct containing the error and, if no error, the content of the resumed [subscription object](https://stripe.com/docs/api/subscriptions/object)
	 */
	ProcessorResponse function resumeSubscription( required subscriptionId, struct metadata = {} ){
		var oResponse = newResponse();

		var processorResponse = variables.stripe.subscriptions.update(
			arguments.subscriptionId,
			{ cancel_at_period_end : false }
		);

		// Associate payment method as default
		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		return oResponse;
	}

	/**
	 * Update the subscription quantity in the provider.
	 * Cancelling a subscription retains access through the end of the billing period.
	 *
	 * @subscriptionId Subscription Id
	 * @quantity       The new quantity, the subscription cost will be calculated based on this number
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 *
	 * @return a struct containing the error and, if no error, the content of the updated [subscription object](https://stripe.com/docs/api/subscriptions/object)
	 */
	ProcessorResponse function updateSubscriptionQuantity(
		required subscriptionId,
		required numeric quantity,
		struct metadata = {}
	){
		var oResponse = newResponse();

		var processorResponse = variables.stripe.subscriptions.update(
			arguments.subscriptionId,
			{ quantity : arguments.quantity }
		);

		// Associate payment method as default
		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		return oResponse;
	}

	/**
	 * Get the payment method struct from the provider
	 *
	 * @subscriptionId The subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 *
	 * @return returns a struct containing error information and, if no error, the content of the [subscription object](https://stripe.com/docs/api/subscriptions/object)
	 */
	ProcessorResponse function getSubscription( required subscriptionId, struct metadata ){
		var subscription = {};
		var oResponse    = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe get provider subscription method starting: #serializeJSON( arguments )#" );
		}

		oResponse.setContent( {} );

		// Find subscription in stripe
		var subscription = variables.stripe.subscriptions.retrieve( arguments.subscriptionId )
		if ( structKeyExists( subscription, "content" ) && !structKeyExists( subscription.content, "error" ) ) {
			oResponse.setContent( subscription.content );
		} else {
			oResponse.setError( true );
			return oResponse;
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe get provider subscription response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Get the customer object from the provider
	 *
	 * @subscriptionId The subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 *
	 * @return struct of: https://stripe.com/docs/api/customers
	 */
	ProcessorResponse function getSubscriptionCustomer( required subscriptionId, struct metadata ){
		var subscription = {};
		var oResponse    = newResponse();

		if ( log.canDebug() ) {
			log.debug(
				"Stripe get provider customer by subscription id method starting: #serializeJSON( arguments )#"
			);
		}

		oResponse.setContent( {} );

		// Find subscription
		var subscription = getSubscription( arguments.subscriptionId );
		if ( subscription.getError() ) {
			oResponse.setError( true );
			return oResponse;
		}

		var customer = getCustomer( subscription.getContent().content?.customer ?: "" );

		if ( customer.getError() ) {
			oResponse.setError( true );
			return oResponse;
		}

		// Set content
		oResponse.setContent( customer.getContent().content );

		if ( log.canDebug() ) {
			log.debug(
				"Stripe get provider customer by subscription id method response: #serializeJSON( oResponse.getContent() )#"
			);
		}

		return oResponse;
	}

	/**
	 * Get the payment method struct from the provider
	 *
	 * @providerCustomerId The provider customer Id to get the payment  method from
	 * @metadata           A struct of metadata to send to the processor (Optional)
	 *
	 * @return struct of: https://stripe.com/docs/api/payment_methods
	 */
	ProcessorResponse function getPaymentMethod( required providerCustomerId, struct metadata ){
		var customer  = {};
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe get payment method starting: #serializeJSON( arguments )#" );
		}

		oResponse.setContent( {} );

		// Get customer struct payment method
		var customer = getCustomer( providerCustomerId );
		if ( customer.getError() ) {
			oResponse.setError( true );
			return oResponse;
		}
		var customerHasPaymentMethod = customer.getContent().content?.invoice_settings?.default_payment_method neq "" ? true : false;

		// Validate and retrieve the customer payment method
		if ( customerHasPaymentMethod ) {
			oResponse.setContent(
				variables.stripe.paymentMethods.retrieve(
					customer.getContent().content.invoice_settings.default_payment_method
				).content
			);
		} else {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe get payment method response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Update payment method
	 *
	 * @customerId      Customer provider ID
	 * @paymentMethodId Payment Method
	 */
	ProcessorResponse function updatePaymentMethod(
		required providerCustomerId,
		required paymentMethodId,
		struct metadata = {}
	){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe Update Payment Method starting: #serializeJSON( arguments )#" );
		}

		// Create payment Method
		var paymentMethod = variables.stripe.paymentMethods.attach(
			arguments.paymentMethodId,
			{ customer : arguments.providerCustomerId }
		).content;

		var processorResponse = variables.stripe.customers.update(
			arguments.providerCustomerId,
			{ invoice_settings : { default_payment_method : paymentMethod.id } }
		);
		// Associate payment method as default

		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe Update Payment Method response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Change from one subscription plan to another one
	 *
	 * @planId         The provider plan Id to change to
	 * @subscriptionId The subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function changeSubscriptionPlan(
		required planId,
		required subscriptionId,
		struct metadata = {}
	){
		var oResponse = newResponse();

		if ( log.canDebug() ) {
			log.debug( "Stripe Change Subscription Plan starting: #serializeJSON( arguments )#" );
		}

		// Retrieve subscription
		var subscription = variables.stripe.subscriptions.retrieve( arguments.subscriptionId ).content;

		var processorResponse = variables.stripe.subscriptions.update(
			arguments.subscriptionId,
			{
				cancel_at_period_end : false,
				proration_behavior   : "create_prorations",
				items                : [
					{
						id   : subscription.items.data[ 1 ].id,
						plan : arguments.planId
					}
				]
			}
		);

		// Associate payment method as default
		oResponse.setContent( processorResponse.content );

		// Check for errors
		if ( processorResponse.status >= 300 ) {
			oResponse.setError( true );
		}

		if ( log.canDebug() ) {
			log.debug( "Stripe  Change Subscription Plan response: #serializeJSON( oResponse.getContent() )#" );
		}

		return oResponse;
	}

	/**
	 * Validate a promotion code
	 *
	 * @code The promotion code to validate
	 */
	ProcessorResponse function validatePromotionCode( required code ){
		var oResponse = newResponse();

		var promotionCodes = variables.stripe.promotionCodes.list( { code : code, active : true, limit : 1 } ).content;

		if ( promotionCodes.data.len() <= 0 ) {
			oResponse.setError( true );
			oResponse.setContent( "Not promotion code found for [#code#]." );
			return oResponse;
		}

		oResponse.setContent( promotionCodes.data[ 1 ] );
		return oResponse;
	}

	/**
	 * Returns an ISO formatted date from unixSeconds
	 *
	 * @epochSeconds
	 */
	string function fromUnixSeconds( required numeric epochSeconds ){
		return getISOTime(
			dateAdd(
				"s",
				arguments.epochSeconds,
				"1970-01-01T00:00:00Z"
			)
		);
	}

	/**
	 * Returns a struct with the formatted content of the charge response
	 *
	 * @content
	 */
	struct function formatChargeResponse( required struct content ){
		var remove             = [ "calculated_statement_descriptor" ];
		content[ "processor" ] = content.calculated_statement_descriptor ?: "Stripe";
		content.created        = content.keyExists( "created" ) ? fromUnixSeconds( content.created ) : javacast(
			"null",
			""
		);
		remove.each( ( key ) => {
			structDelete( content, key );
		} );
		return content;
	}

}
