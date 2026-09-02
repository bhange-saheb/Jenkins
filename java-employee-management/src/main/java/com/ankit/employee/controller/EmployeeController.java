package com.ankit.employee.controller;
import com.ankit.employee.model.Employee; import com.ankit.employee.service.EmployeeService;
import org.springframework.http.*; import org.springframework.web.bind.annotation.*; import java.util.*;
@RestController @RequestMapping("/api")
public class EmployeeController{
 private final EmployeeService service;
 public EmployeeController(EmployeeService service){this.service=service;}
 @GetMapping("/employees") public List<Employee> getAll(){return service.getAll();}
 @GetMapping("/employees/{id}") public Employee getById(@PathVariable Long id){return service.getById(id);}
 @PostMapping("/employees") public ResponseEntity<Employee> create(@RequestBody Employee e){return ResponseEntity.status(HttpStatus.CREATED).body(service.create(e));}
 @PutMapping("/employees/{id}") public Employee update(@PathVariable Long id,@RequestBody Employee e){return service.update(id,e);}
 @DeleteMapping("/employees/{id}") public ResponseEntity<Void> delete(@PathVariable Long id){service.delete(id);return ResponseEntity.noContent().build();}
 @GetMapping("/dashboard") public Map<String,Object> dashboard(){return service.dashboard();}
 @GetMapping("/departments") public List<Map<String,Object>> departments(){return service.departments();}
 @GetMapping("/payroll") public Map<String,Object> payroll(){return service.payroll();}
}
