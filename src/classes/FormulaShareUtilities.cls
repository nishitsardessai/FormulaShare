public with sharing class FormulaShareUtilities {

	public class FormulaShareException extends Exception{}


	public static Schema.sObjectField getSObjectFieldFromName(String fieldNameString, SOBjectType type) {
		Map<String, SObjectField> fieldsMapByName = type.getDescribe().fields.getMap();
		SObjectField sObjField = fieldsMapByName.get(fieldNameString.toLowerCase());
		return sObjField;
	}


	public static Schema.sObjectField getSObjectFieldFromRelatedName(String fieldRelatedNameString, SOBjectType type) {
		// Get a map of all fields for the current object, and loop through each to find the next object to lookup
		Map<String, Schema.SObjectField> fieldsForObject = type.getDescribe().fields.getMap();
		for(Schema.SObjectField field : fieldsForObject.values()) {

			// For joining objects, check whether relationship name of this field is the same as the portion of the lookup we're evaluating
			if(field.getDescribe().getRelationshipName() == fieldRelatedNameString) {
				system.debug('Found related field: '+field);
				return field;
			}
		}
		return null;	// We should have found a field with this relationship name, but return null if not
	}


	public static SObjectType getShareObject(SObjectType type) {
		SObjectType shareObject;
		String typeName = type.getDescribe().getName();
		
		// For custom objects, remove the final "c" from the __c suffix
		if(type.getDescribe().isCustom()) {
			typeName = typeName.left(typeName.length()-1);
		}

		// Append "Share" to get the right object share name
		shareObject = Schema.getGlobalDescribe().get(typeName+'Share');
		
		return shareObject;
	}


	public static Boolean isValidIdType(String candidateId, Schema.SObjectType shareWithType) {
		
		// Accetable if null
		if(candidateId == null) {
			return true;
		}

		else {
			
			// Check we can cast to an Id
			Id idValueToCheck;
			try {
				idValueToCheck = (Id) candidateId;
			}
			catch(Exception e) {
				return false;
			}

			// Check that Id is the expected type
			if(idValueToCheck.getSObjectType() == shareWithType) {
				return true;
			}
			else {
				return false;
			}
		}
	}


	public static String getShareRecordKeyStandard(SOBjectType type, SObject shareRecord) {
		Id parentId = (Id) shareRecord.get(type + 'Id');
		Id userOrGroupId = (Id) shareRecord.get('UserOrGroupId');
		String parentId15 = get15CharacterId(parentId);
		String userOrGroupId15 = get15CharacterId(userOrGroupId);
		String accessLevel = (String) shareRecord.get(type + 'AccessLevel');
		String shareKey = parentId15 + userOrGroupId15 + accessLevel;
		return shareKey;
	}


	public static String getShareRecordKeyCustom(SObject shareRecord) {
		Id parentId = (Id) shareRecord.get('ParentId');
		Id userOrGroupId = (Id) shareRecord.get('UserOrGroupId');
		String parentId15 = get15CharacterId(parentId);
		String userOrGroupId15 = get15CharacterId(userOrGroupId);
		String accessLevel = (String) shareRecord.get('AccessLevel');
		String rowCause = (String) shareRecord.get('RowCause');
		String shareKey = parentId15 + userOrGroupId15 + accessLevel + rowCause;
		return shareKey;
	}


    public static String buildStringFromSetQuotes(Set<Id> idSet) {
        String queryString = '';
        for (Id value : idSet) {
            queryString += '\'' + get15CharacterId(value) + '\',';
        }
        queryString = queryString.substringBeforeLast(',');
        return queryString;
    }


    public static String buildStringFromSetQuotes(Set<String> stringSet) {
        String queryString = '';
        for (String value : stringSet) {
            queryString += '\'' + value + '\',';
        }
        queryString = queryString.substringBeforeLast(',');
        return queryString;
    }


    public static String buildStringFromSetNoQuotes(Set<String> stringSet) {
        String queryString = '';
        for (String value : stringSet) {
            queryString += value + ',';
        }
        queryString = queryString.substringBeforeLast(',');
        return queryString;
    }


	public static String get15CharacterId(Id longId) {
		if(longId != null) {
			String shortId = ((String) longId).left(15);
			return shortId;
		}
		else return null;
	}

}