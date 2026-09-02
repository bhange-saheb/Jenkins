package com.ankit.employee.config;
import com.ankit.employee.model.Employee; import com.ankit.employee.repository.EmployeeRepository;
import org.springframework.boot.CommandLineRunner; import org.springframework.context.annotation.Bean; import org.springframework.context.annotation.Configuration;
@Configuration
public class DataInitializer{
 @Bean CommandLineRunner init(EmployeeRepository r){
  return args->{if(r.count()==0){
   r.save(new Employee("Ankit Bhange","ankit@example.com","Cloud",85000.0));
   r.save(new Employee("Rahul Sharma","rahul@example.com","DevOps",75000.0));
   r.save(new Employee("Priya Patel","priya@example.com","Engineering",90000.0));
   r.save(new Employee("Neha Kulkarni","neha@example.com","Finance",78000.0));
  }};
 }
}
