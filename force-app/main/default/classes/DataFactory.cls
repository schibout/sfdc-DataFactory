global without sharing class DataFactory {

    /**
     * Generates an sObject of a given type. 
     * 
     * The sObject itself does not include the Fields properties of the
     * desired type. Fields can either be set using `put(fieldName, value)`
     * or by casting the object to the desired type.
     * 
     * @param typeName  Name of the Object type to create.
     * @return  A single Object.
     */
    public static sObject one(String typeName) {
        return Schema.getGlobalDescribe().get(typeName).newSObject();
    }

    /**
     * Generates a list of SObjects with a given size and of a given type. 
     * 
     * The sObject itself does not include the Fields properties of the
     * desired type. Fields can either be set using `put(fieldName, value)`
     * or by casting the object to the desired type.
     * 
     * @param typeName  Name of the Object type to create.
     * @param count A number of SObjects to generate.
     * @return  A List of SObjects.
     */
    public static List<sObject> many(String typeName, Integer count) {
        List<sObject> newObjects = new List<sObject>();
        while (count > 0) {
            newObjects.add(one(typeName));
            count--;
        }
        return newObjects;
    }

}
