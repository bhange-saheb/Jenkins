package com.ankit.employee.controller;
import com.ankit.employee.model.Employee; import com.ankit.employee.service.EmployeeService;
import com.fasterxml.jackson.databind.ObjectMapper; import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired; import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean; import org.springframework.http.MediaType; import org.springframework.test.web.servlet.MockMvc;
import java.util.List; import static org.mockito.ArgumentMatchers.any; import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*; import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
@WebMvcTest(EmployeeController.class)
class EmployeeControllerTest{
 @Autowired MockMvc mockMvc; @MockBean EmployeeService service; @Autowired ObjectMapper mapper;
 @Test void employees() throws Exception{Employee e=new Employee("Ankit Bhange","a@x.com","Cloud",85000.0);when(service.getAll()).thenReturn(List.of(e));mockMvc.perform(get("/api/employees")).andExpect(status().isOk()).andExpect(jsonPath("$[0].name").value("Ankit Bhange"));}
 @Test void dashboard() throws Exception{when(service.dashboard()).thenReturn(java.util.Map.of("totalEmployees",4,"departments",3,"monthlyPayroll",328000.0,"averageSalary",82000.0));mockMvc.perform(get("/api/dashboard")).andExpect(status().isOk()).andExpect(jsonPath("$.totalEmployees").value(4));}
}
