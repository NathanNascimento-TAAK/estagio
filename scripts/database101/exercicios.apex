//Insert Student
public Id insertStudent(String name, String email) {
    apxio__Student__c newAcct = new apxio__Student__c(Name = name, apxio__Email__c= email);
    insert newAcct;

    return newAcct.Id;
}

//Insert Course
public Id insertCourse(String name, String details, Integer credits) {
    if(credits < 1 || credits > 4) return null;
    apxio__Course__c newCourse = new apxio__Course__c(Name = name, apxio__Course_Details__c = details, apxio__Credits__c = String.valueOf(credits));

    insert newCourse;
    
    return newCourse.Id;
}

//Register Student
public String registerStudent(String name, String phone, String email) {
    apxio__Student__c newStudent = new apxio__Student__c(Name = name, apxio__Email__c = email, apxio__Phone__c = phone);

    insert newStudent;

    apxio__Student__c student = [SELECT apxio__Registration_Number__c FROM apxio__Student__c WHERE apxio__Email__c = :email LIMIT 1];

    return student.apxio__Registration_Number__c;
}

//Active Students
public List<apxio__Student__c> selectActiveStudents() {
    List<apxio__Student__c> estudantesAtivos = [SELECT Name FROM apxio__Student__c WHERE apxio__Active__c = true];

    return estudantesAtivos;
}

//Unreachable Students
public List<apxio__Student__c> selectUnreachableStudents() {
    List<apxio__Student__c> unreachable = [SELECT Id, Name FROM apxio__Student__c WHERE apxio__Active__c = true AND apxio__Phone__c = null AND apxio__Email__c = null ORDER BY Name];

    return unreachable;
}

//Students Missing Info
public List<apxio__Student__c> selectStudentsWithoutContactInfo() {
    List<apxio__Student__c> noContact = [SELECT Id, Name FROM apxio__Student__c WHERE apxio__Phone__c = null ORDER BY Name];

    return noContact;
}

//Course and Class
public void createCourseAndClass(String name, String description) {
    if(String.isBlank(description)) description = '';
    String descricao255 = description;
    if(description.length() > 255) descricao255 = description.left(255);
    apxio__Course__c course = new apxio__Course__c(Name = name, apxio__Course_Details__c = description);
    insert course;
    apxio__Class__c classe = new apxio__Class__c(Name = course.Name, apxio__Course__c = course.Id, apxio__Description__c = descricao255);
    insert classe;
}

//Student list
public void insertStudents(List<String> studentNames, List<String> studentEmails) {
    List<apxio__Student__c> studentsInsert = new List<apxio__Student__c>();    
    for(Integer i = 0; i < studentNames.size(); i++) {
        studentsInsert.add(new apxio__Student__c(Name = studentNames[i], apxio__Email__c = studentEmails[i]));
    }
    insert studentsInsert;
}

//Class from Course
public Id classFromCourse(String courseName) {
    List<apxio__Course__c> courses = new List<apxio__Course__c>();
    courses = [SELECT Id, Name FROM apxio__Course__c WHERE Name = :courseName LIMIT 1];
    if(courses.size() == 0) return null;
    apxio__Class__c newClass = new apxio__Class__c(Name = courses[0].Name, apxio__Course__c = courses[0].Id);
    insert newClass;
    return newClass.Id;
}

//Enroll Students
public void enrollStudents(List<String> emails, String className) {
    List<apxio__Student__c> students = [SELECT Id FROM apxio__Student__c WHERE apxio__Email__c = :emails];
    List<apxio__Class__c> classes = [SELECT Name FROM apxio__Class__c WHERE Name = :className];
    List<apxio__Class_Enrollment__c> classEnrollments = new List<apxio__Class_Enrollment__c>();
    for(apxio__Student__c student : students) {
        classEnrollments.add(new apxio__Class_Enrollment__c(apxio__Student__c = student.Id, apxio__Offered_Class__c = classes[0].Id));
    }
    insert classEnrollments;
}

