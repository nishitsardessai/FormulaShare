public with sharing class FormulaShareSettings {
	
	public class FormulaShareException extends Exception{}

	static FormulaShare_Settings__mdt settings;

	public static FormulaShare_Settings__mdt getFormulaShareSettings() {

		if(settings == null) {
			settings = queryFormulaShareSettings();
		}

		return settings;
	}

	private static FormulaShare_Settings__mdt queryFormulaShareSettings() {
		
		List<FormulaShare_Settings__mdt> settingsList =
			[SELECT DeveloperName, Recalculation_Batch_Size__c, Remove_Shares_for_Standard_Objects__c
			FROM FormulaShare_Settings__mdt WHERE Active__c = true];

		if(!settingsList.isEmpty()) {
			// Return the first active setting
			return settingsList[0];
		}

		else throw new FormulaShareException();
	}

}