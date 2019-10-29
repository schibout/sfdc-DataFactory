# Salesforce Apex DataFactory

The `DataFactory` is a Salesforce Apex class that provides a standard model for generating data.
 
This allows for managing the creation of data, particuarlly for Apex Testing, in one place. Additionally, this made it possible to build an configurable extension framework that allows for custom data factories adapted to the unique contraints of each Salesforce Org.

For example, when writing a Salesforce App that generates Contact records, even if only for Apex Tests, your Apex code may look like

```java
Contact aContact = new Contact(LastName='Tester');
insert aContact;
```

However, if a Validation Rules is added to the Org requiring Contact's have a First Name, the code can throw an error.

In a unmanaged package the Apex code can be changed, but that means someone has to maintain the new code. If the code was found in an open source project, such as from GitHub, that means maintaing a fork of the project which can make future updates more complicated.

`DataFactory` provides an abstraction over record creation providing an new way to manage Org-specific requirements without overwriting code.

```java
Contact aContact = (Contact)DataFactory.one('Contact');
insert aContact;
```

`DataFactory.one('Contact')` creates a single Contact record, but is different from `new Contact()` in that the record is created through an extendable Apex class.

In a standard Salesforce Org, that Apex class might look like 

```java
public class ContactFactory extends DataFactory.sObjectFactory {
    public ContactFactory {
        super('Contact');
    }

    public SObject make() {
        return new Contact(LastName='Tester');
    }
}
```

But in an Org with a Contact Validation Rule, a new Contact Factory can account for new conditions.

```java
public class MyContactFactory extends DataFactory.sObjectFactory {
    public ContactFactory {
        super('Contact');
    }

    public SObject make() {
        return new Contact(
            FirstName='John',
            LastName='Tester'
        );
    }
}
```

Once this Apex Class is registered in the `SObjectFactory` Custom Metadata Types, any call to `DataFactory.one('Contact')` will return a Contact record with both a First and Last Name.

## SObjectFactory Metadata Type

The `SObjectFactory` Custom Metadata Type is used to register an SObjectFactory class for the `DataFactory`.

For example, the above `ContactFactory` can be registered to `DataFactory.one('Contact')` with the SObjectFactory

| Label | Value |
| --- | --- |
| Label | `Contact` |
| Apex Class | `ContactFactory` |

The Apex Class can then be updated in the target Org to point to the new SObjectFactory

| Label | Value |
| --- | --- |
| Label | `Contact` |
| Apex Class | `MyContactFactory` |

> It is recommended, but not _required_, that registered a SObjectFactory Label refers to a Salesforce object by API Name, e.g. `Contact` or `MyCustomObject__c`, or `pkg__NewObject__c` so that DataFactory calls can be made based on the desired object type, e.g. `DataFactory.one('Contact')`.

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