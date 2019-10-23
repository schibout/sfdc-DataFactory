# Salesforce Apex DataFactory

The `DataFactory` is a Salesforce Apex class that provides a standard model for generating data.

By defining a standard model, it becomes possible to to build an configurable extension framework that can allow for custom data factories adapted to the unique contraints of each Salesforce Org.

For example, when writing a Salesforce App that generates Contact records, even if only for Apex Tests, by default Salesforce only requires that Contacts have a Last Name, so your Apex code may look like

```java
Contact aContact = new Contact(LastName='Tester');
insert aContact;
```

However, when this code is deployed and execute in a Salesfroce Org with a Validation Rule ensuring the Contacts also have First Names, the code can throw an error.

While the code can be adjusted to meet the new requirements in a unmanaged package, this can result in each implementation diverging from the original code repository, forcing everyone to maintian their own fork of the project.

The `DataFactory` provides an abstraction over this record creation, for example

```java
Contact aContact = (Contact)DataFactory.get('Contact').one();
insert aContact;
```

How does this work?

`DataFactory.get('Contact')` returns factory class that implements a `one()` method to generate a single Contact record.

In a default Salesforce implementation, this Contact DataFactory may look like

```java
public class ContactFactory implements DataFactory.sObjectFactory {
    public SObject one() {
        return new Contact(LastName='Tester');
    }
}
```

But in an Org with a Contact Validation Rule, a new Contact Data Factory can be written to account for this new condition.

```java
public class MyContactFactory implements DataFactory.sObjectFactory {
    public SObject one() {
        return new Contact(
            FirstName='John',
            LastName='Tester'
        );
    }
}
```

Once this class is registered in the DataFactory_Object Custom Metadata Type, the `DataFactory.get('Contact').one();` operation works in the new environment without changing the tests.

While this package includes a `DataFactory` Apex class that can be deployed and used in a Salesforce Org, the implementation is, at this time, overly simple and not of much use. Instead, this project should be used as a template for implementing an extensible `DataFactory` into your own project.

## Developer Setup and Build

This project is maintainted as Salesforce DX _source_ and requires the [Salesforce CLI] `sfdx`. 

It is recommended to work on this project in a Salesforce Scratch Org which requires a Salesforce Org with the DevHub feature enabled. This can be any production environment, including a free [Developer Org].

Login to your DevHub Org.

```
sfdx force:auth:web:login
```

Create the Scratch Org from the DevHub Org.

```
sfdx force:org:create --setdefaultusername --definitionfile=config/project-scratch-def.json --targetdevhubusername=targetdevhubusername
```

> It is optional, but recommended, to use the `--setdefaultusername` flag which binds the Scratch Org to the project's default Org, and avoids needed to keep track of the Scratch Orgs Username for use in other commands.

Push the source into the Scratch Org

```
sfdx force:source:push
```

> If not using the `--setdefaultusername` flag, you will need to use the `--targetusername=targetusername` option for the push command.


[Salesforce CLI]: https://developer.salesforce.com/tools/sfdxcli
[Developer Org]: https://developer.salesforce.com/signup