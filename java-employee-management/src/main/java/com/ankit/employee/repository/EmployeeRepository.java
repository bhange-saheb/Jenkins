package com.ankit.employee.repository;
import com.ankit.employee.model.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
public interface EmployeeRepository extends JpaRepository<Employee,Long>{}
