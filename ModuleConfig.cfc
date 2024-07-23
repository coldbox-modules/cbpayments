/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

	// Module Properties
	this.title       = "cbpayments";
	this.author      = "Ortus Solutions";
	this.webURL      = "https://www.ortussolutions.com";
	this.description = "A module providing a common interface and API for processing payments and subscriptions'";
	this.version     = "@build.version@+@build.number@";

	// Model Namespace
	this.modelNamespace = "cbpayments";

	// CF Mapping
	this.cfmapping = "cbpayments";

	// Dependencies
	this.dependencies = [];

	/**
	 * Configure Module
	 */
	function configure(){
		settings = {};
	}

	/**
	 * Fired when the module is registered and activated.
	 */
	function onLoad(){
	}

	/**
	 * Fired when the module is unregistered and unloaded
	 */
	function onUnload(){
	}

}
