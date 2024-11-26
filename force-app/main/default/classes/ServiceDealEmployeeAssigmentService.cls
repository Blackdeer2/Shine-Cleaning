public with sharing class ServiceDealEmployeeAssigmentService {
    @AuraEnabled
    public static void addEmployee(Id serviceId) {
        Service_Deal__c serviceDeal = [
            SELECT Id, Start_Date__c, Close_Date__c
            FROM Service_Deal__c
            WHERE Id = :serviceId
            LIMIT 1
        ];

        List<Employee__c> emploees = [
            SELECT
                Id,
                (
                    SELECT Id, Status__c, Service_Deal__c, Service_Deal__r.Start_Date__c, Service_Deal__r.Close_Date__c
                    FROM Assignments__r
                )
            FROM Employee__c
        ];

        Employee__c employeeToAssign = new Employee__c();

        Map<Id, Integer> countOfAssignments = new Map<Id, Integer>();
        Integer minCount = 100000; // зробити присвоєння першого значення з мапи

        List<Employee__c> employeesToRemove = new List<Employee__c>();
        for (Employee__c empl : emploees) {
            for (Assignment__c assignment : empl.Assignments__r) {
                if (
                    assignment.Service_Deal__r.Start_Date__c <= serviceDeal.Close_Date__c &&
                    assignment.Service_Deal__r.Close_Date__c >= serviceDeal.Start_Date__c
                ) {
                    employeesToRemove.add(empl);
                    break;
                }
            }
        }
        for (Integer i = emploees.size() - 1; i >= 0; i--) {
            Employee__c emplToRemove = emploees[i];
            if (employeesToRemove.contains(emplToRemove)) {
                emploees.remove(i);
            }
        }

        for (Employee__c empl : emploees) {
            Integer pendingAssignmentsCount = 0;

            for (Assignment__c assignment : empl.Assignments__r) {
                if (assignment.Status__c == 'On Pending' || assignment.Status__c == 'Assigned/In Work') {
                    pendingAssignmentsCount++;
                }
            }

            countOfAssignments.put(empl.Id, pendingAssignmentsCount);
        }
        system.debug('countOfAssignments ' + countOfAssignments);
        for (Id employeeId : countOfAssignments.keySet()) {
            Integer currentCount = countOfAssignments.get(employeeId);
            if (currentCount < minCount) {
                minCount = currentCount;
                employeeToAssign.Id = employeeId;
            }
        }
        system.debug('employeeToAssign ' + employeeToAssign.Id);
        if (employeeToAssign.Id != null) {
            String name = [SELECT Name FROM Employee__c WHERE Id = :employeeToAssign.Id LIMIT 1].Name;
            Assignment__c newAssignment = new Assignment__c(
                Name = name + ' Auto assigned',
                Employee__c = employeeToAssign.Id,
                Service_Deal__c = serviceDeal.Id,
                Status__c = 'On Pending'
            );
            insert newAssignment;
        } else {
            throw new AuraHandledException('No available employees for this service deal at this time.');
        }
    }
}