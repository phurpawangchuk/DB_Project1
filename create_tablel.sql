CREATE TABLE student(
    studentId int not null,
    studentName varchar(255),
    gender varchar(1),
    address varchar(255),
    email varchar(255),
    PRIMARY KEY(studentId)
);


CREATE TABLE assignment (
    assignmentId int not null,
    assign_due_date date,
    assign_description varchar(255),
    assign_created_date date,
    PRIMARY KEY(assignmentId)
);

CREATE TABLE student_assignment (
    assignmentId int not null,
    assignment_numeric_grade int,
    assignment_letter_grade varchar(2),
    assignment_submission_date date,
    assignment_graded_date date,
    assignment_returned_date date,
    studentId int,
    PRIMARY KEY(assignmentId),
    FOREIGN KEY(studentId) REFERENCES student(studentId),
    FOREIGN KEY(assignmentId) REFERENCES assignment(assignmentId)
);


CREATE TABLE course (
  courseId int not null,
  courseCode varchar(50),
  courseName varchar(255),
  PRIMARY KEY(courseId)
);

CREATE TABLE student_course (
    id int not null,
    studentId int,
    courseId int,
    stdcourse_numeric_grade int,
    stdcourse_letter_grade varchar(2),
    PRIMARY KEY(studentId,courseId),
    FOREIGN KEY(studentId) REFERENCES student(studentId),
    FOREIGN KEY(courseId) REFERENCES course(courseId)
);

CREATE TABLE instructor (
    instructorId int not null,
    instructorName varchar(255),
    PRIMARY KEY(instructorId)
);

CREATE TABLE course_instructor (
    id int not null,
    courseId int,
    instructorId int,
    PRIMARY KEY(id),
    FOREIGN KEY(courseId) REFERENCES course(courseId),
    FOREIGN KEY(instructorId) REFERENCES instructor(instructorId)
);