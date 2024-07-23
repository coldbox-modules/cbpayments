/**
 * A Base processor utility
 */
component accessors="true" {

	// Global DI
	property name="wirebox" inject="wirebox";
	property name="log"     inject="logbox:logger:{this}";

	/**
	 * Get a new reponse object
	 */
	function newResponse() provider="ProcessorResponse@cbpayments"{
	}

	/**
	 * Retrieve a human readable name for the processor
	 */
	function getName(){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * If there is a version attached to the processor then return it here.
	 */
	function getVersion(){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Get the payment processor SDK library implementation.  This will be getting the raw processor.
	 */
	any function getProcessor(){
		throw( "This method must be implemented in the child processor" );
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
	 */
	ProcessorResponse function preAuthorize(
		required numeric amount,
		required source,
		currency = "usd",
		customerId,
		description     = "",
		struct metadata = {}
	){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Make a charge on the processor.  Please note that any EXTRA arguments added to a processor
	 * The processor implementation must take care of them.
	 *
	 * @amount      The amount in cents to charge, example: $20 = 2000, $20.5 = 2050, it is required
	 * @source      A payment source to be charged, usually this is a card token, a customer token, etc. It is required
	 * @currency    Usually the three-letter ISO Currency code (Optional)
	 * @customerId  A customer identifier to attach to the charge (Optional)
	 * @description The description of the charge (Optional)
	 * @metadata    A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function charge(
		required numeric amount,
		required source,
		currency,
		customerId,
		description,
		boolean capture = true,
		struct metadata = {}
	){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Make a refund on the processor.  Please note that any EXTRA arguments added to a processor
	 * The processor implementation must take care of them.
	 *
	 * @charge   The identifier of the charge to refund.
	 * @amount   The amount in cents to refund, if not sent then the entire charge is refunded (Optional)
	 * @reason   A reason of why the refund (Optional)
	 * @headers  A struct of headers to send with the processor (Optional)
	 * @metadata A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function refund(
		required charge,
		numeric amount,
		reason,
		struct metadata = {}
	){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Create a subscription in the provider
	 * The processor implementation must take care of them.
	 *
	 * @providerCustomerId The provider customer Id
	 * @planId             Plan Id in the provider
	 * @metadata           A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function createSubscription(
		required providerCustomerId,
		required planId,
		numeric quantity,
		struct metadata = {}
	){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Get the subscription from the provider
	 * The processor implementation must take care of them.
	 *
	 * @subscriptionId The Subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function getSubscription( required subscriptionId, struct metadata = {} ){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Cancel a subscription in the provider.
	 * Cancelling a subscription retains access through the end of the billing period.
	 *
	 * @subscriptionId Subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function cancelSubscription( required subscriptionId, struct metadata = {} ){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Resume a subscription in the provider.
	 *
	 * @subscriptionId Subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function resumeSubscription( required subscriptionId, struct metadata = {} ){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Update the subscription quantity in the provider.
	 * Cancelling a subscription retains access through the end of the billing period.
	 *
	 * @subscriptionId Subscription Id
	 * @quantity       The new quantity, the subscription cost will be calculated based on this number
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function updateSubscriptionQuantity(
		required subscriptionId,
		required numeric quantity,
		struct metadata = {}
	){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Delete a subscription in the provider
	 * The processor implementation must take care of them.
	 *
	 * @subscriptionId Subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function deleteSubscription( required subscriptionId, struct metadata = {} ){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Convenience method to retrieve the customer associated with a subscription
	 *
	 * @subscriptionId The subscription Id
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function getSubscriptionCustomer( required subscriptionId, struct metadata ){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Create a customer in the provider
	 * The processor implementation must take care of them.
	 *
	 * @email           Email of the new customer
	 * @paymentMethodId Payment Method Id of the provider
	 * @description     Customer description, very handy info that could be found in the provider
	 * @metadata        A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function createCustomer(
		required email,
		required paymentMethodId,
		description,
		struct metadata = {}
	){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Get the customer struct from the provider
	 * The processor implementation must take care of them.
	 *
	 * @providerCustomerId The provider customer Id
	 * @metadata           A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function getCustomer( required providerCustomerId, struct metadata = {} ){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Get the customer payment method
	 * The processor implementation must take care of them.
	 *
	 * @providerCustomerId The provider customer Id
	 * @metadata           A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function getPaymentMethod( required providerCustomerId, struct metadata = {} ){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Update the payment method associated to a customer
	 * The processor implementation must take care of them.
	 *
	 * @customerId      The customer Id in the provider
	 * @paymentMethodId The Payment Method Id generated by the provider
	 * @metadata        A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function updatePaymentMethod(
		required providerCustomerId,
		required paymentMethodId,
		struct metadata = {}
	){
		throw( "This method must be implemented in the child processor" );
	}

	/**
	 * Change from one subscription plan to another one
	 *
	 * @planId         The provider plan Id to change to
	 * @subscriptionId The subscription Id in the provider
	 * @metadata       A struct of metadata to send to the processor (Optional)
	 */
	ProcessorResponse function changeSubscriptionPlan(
		required planId,
		required subscriptionId,
		struct metadata = {}
	){
		throw( "This method must be implemented in the child processor" );
	}

}

