@isTest
public class ServiceDealEmployeeAssigmentServiceTest {
    @testSetup
    static void setupTestData() {
        Property__c prop = new Property__c(Name = 'Test Property');
        insert prop;

        Service_Deal__c serviceDeal = new Service_Deal__c(
            Property__c = prop.Id,
            Start_Date__c = DateTime.now(),
            Close_Date__c = DateTime.now().addDays(10)
        );
        insert serviceDeal;

        List<Employee__c> employees = new List<Employee__c>();
        for (Integer i = 1; i <= 5; i++) {
            employees.add(new Employee__c(Name = 'Employee ' + i));
        }
        insert employees;

        List<Assignment__c> assignments = new List<Assignment__c>();
        for (Integer i = 0; i < 4; i++) {
            assignments.add(
                new Assignment__c(
                    Employee__c = employees[i].Id,
                    Service_Deal__c = serviceDeal.Id,
                    Status__c = 'Assigned/In Work'
                )
            );
        }
        insert assignments;
    }

    @isTest
    static void testAddEmployeeWithAvailableEmployee() {
        Service_Deal__c serviceDeal = [SELECT Id FROM Service_Deal__c LIMIT 1];

        Test.startTest();
        ServiceDealEmployeeAssigmentService.addEmployee(serviceDeal.Id);
        Test.stopTest();

        List<Assignment__c> createdAssignments = [
            SELECT Id, Employee__c, Service_Deal__c, Status__c
            FROM Assignment__c
            WHERE Service_Deal__c = :serviceDeal.Id AND Status__c = 'On Pending'
        ];
        System.assertEquals(1, createdAssignments.size(), 'One assignment should be created');
        System.assertEquals('On Pending', createdAssignments[0].Status__c, 'Status should be "On Pending"');

        System.debug('Created Assignment: ' + createdAssignments[0]);
    }
}