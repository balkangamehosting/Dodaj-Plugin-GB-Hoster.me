<?php

session_start();
error_reporting(0);
include 'assets/include/db_connect.php';

      // Configuration
      $results_per_page = 10;
      $page_name = "users.php";
      $page_get = "page";
      
      $sql = 'SELECT * FROM users ORDER BY user_id DESC';
      $result1 = mysqli_query($conn, $sql);
      
      $number_of_results = mysqli_num_rows($result1);
      
      $number_of_pages = ceil($number_of_results/$results_per_page);
  
      if (!isset($_GET[$page_get])) {
        $page = 1;
      } else {
        $page = $_GET[$page_get];
      }


      $this_page_first_result = ($page-1)*$results_per_page;  

$output = '';

if(isset($_POST["query"]))
{
 $search = mysqli_real_escape_string($conn, $_POST["query"]);
 $query = "
  SELECT * FROM users 
  WHERE username LIKE '%".$search."%'
  OR fullname LIKE '%".$search."%' LIMIT " . $this_page_first_result . ',' .  $results_per_page;
}
else
{
 $query = "
  SELECT * FROM users ORDER BY user_id DESC LIMIT " . $this_page_first_result . ',' .  $results_per_page;
}
$result = mysqli_query($conn, $query);
//if(mysqli_num_rows($result) > 0)
//{
 $output .= '
   <table>
      <tr>
        <th> ID </th>
        <th> Username </th>
        <th> Permisija </th>
        <th> Datum Registracije </th>
        <th> Status </th> 
      </tr>
 ';
 while($row = mysqli_fetch_array($result))
 {

         if ($row['privilegija'] == 0) {
          $userlink = "<span style='color:white;'>$dodao[username]</span>";
         }

         if ($row['privilegija'] == 1 OR $row['privilegija'] == 2) {
          $userlink = "<span style='color:red;'>$dodao[username]</span>";
         }

  $output .= '
   <tr>
    <td>'.$row["user_id"].'</td>
    <td>'.$row["username"].'</td>
    <td>'.$userlink.'</td>
    <td>'.$row["datum"].'</td>
    <td>Uskoro</td>
   </tr>
  ';
 }

 echo $output;
//}
//else
//{
 //echo 'Data Not Found';
//}

?>