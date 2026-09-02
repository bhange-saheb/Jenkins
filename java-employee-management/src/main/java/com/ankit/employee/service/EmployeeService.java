package com.ankit.employee.service;
import com.ankit.employee.exception.EmployeeNotFoundException;
import com.ankit.employee.model.Employee;
import com.ankit.employee.repository.EmployeeRepository;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;
@Service
public class EmployeeService{
 private final EmployeeRepository repository;
 public EmployeeService(EmployeeRepository repository){this.repository=repository;}
 public List<Employee> getAll(){return repository.findAll();}
 public Employee getById(Long id){return repository.findById(id).orElseThrow(()->new EmployeeNotFoundException(id));}
 public Employee create(Employee e){return repository.save(e);}
 public Employee update(Long id,Employee d){Employee e=getById(id);e.setName(d.getName());e.setEmail(d.getEmail());e.setDepartment(d.getDepartment());e.setSalary(d.getSalary());return repository.save(e);}
 public void delete(Long id){if(!repository.existsById(id))throw new EmployeeNotFoundException(id);repository.deleteById(id);}
 public Map<String,Object> dashboard(){
  List<Employee> es=getAll(); double payroll=es.stream().mapToDouble(e->e.getSalary()==null?0:e.getSalary()).sum();
  double avg=es.isEmpty()?0:payroll/es.size();
  long departments=es.stream().map(Employee::getDepartment).filter(Objects::nonNull).filter(s->!s.isBlank()).distinct().count();
  return Map.of("totalEmployees",es.size(),"departments",departments,"monthlyPayroll",payroll,"averageSalary",avg);
 }
 public List<Map<String,Object>> departments(){
  Map<String,List<Employee>> grouped=getAll().stream().collect(Collectors.groupingBy(e->e.getDepartment()==null||e.getDepartment().isBlank()?"Unassigned":e.getDepartment(),TreeMap::new,Collectors.toList()));
  return grouped.entrySet().stream().map(x->Map.<String,Object>of("name",x.getKey(),"employeeCount",x.getValue().size(),"payroll",x.getValue().stream().mapToDouble(e->e.getSalary()==null?0:e.getSalary()).sum())).toList();
 }
 public Map<String,Object> payroll(){
  List<Employee> es=getAll(); double total=es.stream().mapToDouble(e->e.getSalary()==null?0:e.getSalary()).sum();
  return Map.of("totalPayroll",total,"averageSalary",es.isEmpty()?0:total/es.size(),"employees",es);
 }
}
