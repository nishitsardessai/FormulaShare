public class ProcessFormulaShareBatch implements Database.Batchable<sObject> {
	
	List<Schema.SObjectType> types;
	Integer batchSize;
	Schema.SObjectType typeInThisBatch;
	FormulaShareService.RulesForTypeWrapper typeRules;

	// Accepts a list of types. Chained batches will be submitted if more than one type is provided
	public ProcessFormulaShareBatch(List<Schema.SObjectType> types, Integer batchSize) {
		this.types = types;
		this.batchSize = batchSize;
		this.typeInThisBatch = types[0];
		this.typeRules = new FormulaShareService.RulesForTypeWrapper(typeInThisBatch);
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('FormulaShare batch job started. Type in scope: '+typeInThisBatch);
		system.debug('Type rules object: '+typeRules);
		String query = FormulaShareService.getFullObjectQuery(typeRules);
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		FormulaShareService.FormulaShareWrapper fsWrapper = new FormulaShareService.FormulaShareWrapper(typeRules);
		
		// Populate records map in wrapper
		for(SObject obj : scope) {
			fsWrapper.recordsMap.put(obj.Id, obj);
		}
		system.debug('scope: '+scope);

		FormulaShareService.processFormulaShares(fsWrapper);
	}
	
	public void finish(Database.BatchableContext BC) {
		
		// If there are more types to process, submit another batch
		if(types.size() > 1) {
			types.remove(0);
			Id batchJobId = Database.executeBatch(new ProcessFormulaShareBatch(types, batchSize), batchSize);
			system.debug('Submitted next batch, Id = ' + batchJobId);
		}

	}
	
}