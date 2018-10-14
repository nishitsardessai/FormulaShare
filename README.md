# FormulaShare, apex sharing for admins

Click-and-configure rules to share records to users and roles based on data related to the record to be shared.

Salesforce provides great in-platform options for sharing records - ownership based, criteria based, manual sharing and apex sharing.
However there's a key use case missing - the ability to share to users identifiable from the Salesforce data itself.

FormulaShare provides that ability without resorting to complex development!

* Records can be automatically shared to any user, role or group specified in a formula field
* FormulaShare creates related object share records for new and modified records in real time
* FormulaShare recalculates sharing after changes to related records in scheduled or ad hoc batch calculcations
* Rules are configured in custom metadata, so can be tested in sandboxes and deployed to production
* Any custom or standard objects supporting manual sharing and set to Private or Public Read Only are supported
* Records can be shared with Read, Edit or All levels of access
* Works with Classic and Lightning
* Powered by Salesforce apex / managed sharing

## Design approach

By leveraging the capabilities of formula fields, FormulaShare allows admins to easily create and manage rules sharing records to 
everyone needing access. Complex relationships and conditions can be built into the formula fields themselves if needed.

Real time sharing calculation if needed is kicked off from apex triggers, but only one line of code needs to the trigger or handler class needs to be added to make sure this happens. Processing is delegated to a queueable apex method to preserve performance and governer limits - no additional synchronous SOQL is called within the trigger transaction.

Apex sharing is notoriously difficult to implement successfully - FormulaShare handles many changes leading to sharing changes in real 
time (for example creation of records and changes to formula field values), and processes all other changes which in a catch-up batch job
(e.g., changes to a related object referenced by a formula field).

## Technical configuration

Once code from the repo is implemented, two key steps are needed to set up FormulaShare:

* **Call FormulaShareService from shared object triggers** One line of code is needed to call FormulaShare. Add this line to any triggers or any handler code called by your triggers:

FormulaShareService.triggerHandler();

That's it! This line will call a method in FormulaShareService which assesses whether sharing changes are needed on created or modified records of the object the trigger was called from. If you use a trigger framework with a central handler delegating processing for all triggers, the line can be added in this class instead of adding a line for each object's trigger.

* **Schedule batch recalculation of FormulaShare rules** [Schedule](https://help.salesforce.com/articleView?id=code_schedule_batch_apex.htm&type=5) the class FormulaShareProcessSchedulable to recalculate all rules

## Setting up a FormulaShare rule

### Create sharing field
First create a field on the object which should be shared. The field should be populated with the Salesforce record Id (either the 15 or 18 character version) indicating the user, group or role which the record should be with. This could be a formula field returning text with the Id, but could alternatively be a lookup field to the User object, or even a text field populated with an Id manually or through automation.

### Create sharing reason (custom objects only)
FormulaShare will create entries in the shared object's linked share table with a configured sharing reason, which ensures FormulaShare can keep track of all records shared for this sharing reason, and can easily remove sharing when no longer required. Set up a sharing reason (Classic only) from the custom object's setup page in the section "Apex Sharing Reasons". Note that if using the Lightning interface, sharing reasons can be set up by temporarily switching to Salesforce Classic.

For standard objects sharing reasons aren't supported by Salesforce. As an alternative, FormulaShare provides options to process rules either as additive (so object sharing is not removed if data conditions change), or fully managed (meaning FormulaShare assumes all records in the object's share table are provided by the configured rule and removes sharing which doesn't meet the criteria of the rule).

### Create FormulaShare rule record
From the Setup menu, type "Custom Metadata Types" and click "Manage Records" for FormulaShare Rule. Each of the custom metadata records are the settings for a single rule. The following fields define the setup of each rule:
* **Name** and **Label**: Add something to distinguish this rule from others
* **Shared Object**: The API name (including "__c") of the object with records to be shared
* **Shared To Field**: The API name (including "__c") of the field on the object above which is populated an Id
* **Share With**: The type of entity this rule should share with. Options are "Users", "Roles", "Roles and Internal Subordinates" and "Public Groups"
* **Sharing Reason**: For custom objects, the sharing reason that share records should use


* **Access Level**: Set to Read (users are shared relevant records in read-only), Edit (shared in read-write mode) or All (users are able to read, edit and transfer ownership of the record)
* 

### Test configuration

## Example applications

* In a recruitment system, share job records and applications to the relevant hiring manager user and recruitment team
* Share cases to account executive teams, but only when these are not flagged as containing sensitive data
* In a multi-territory org, share custom objects to the group working in each territory with a single rule
* In a global org, share records to the relevant roles specified on a linked custom country object
* Share records to all users with the same role as the record owner
* Conditionally share records based on the value in a lookup or formula field (field types not available in standard sharing rules)
* Provide a field on a record for users to share ad hoc to colleagues

## How does it work?

FormulaShare 

## Areas for future development

The project is currently in beta. Code provided should work but no promises included! The following is a list of areas which will be worked on in due course:
* Apex unit tests for all code
* Automated deployment of triggers and sharing reasons using metadata API (a la the wonderful [DeclareativeLookupRollupSummary](https://github.com/afawcett/declarative-lookup-rollup-summaries))
* Packaging into a managed package and publication on AppExchange
* Managed scheduling of batch job and configuration parameters in managed package setup
* Lightning interface for metadata rule configuration
* Improved error handling and validation
* Ability to process standard object sharing as either additive or fully managed
* Support for account teams and territory groups
* Support for assessing user roles directly without a formula field being needed

## Ethos

FormulaShare is developed as a community project and is free to use and distribute. Contributions, collaborations, feedback and suggestions are welcome.
