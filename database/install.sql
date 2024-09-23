DELETE FROM api_process_log WHERE event_handler_id IN (SELECT id FROM api_event_handler WHERE solution_id=10005);
DELETE FROM api_group_permission WHERE solution_id=10005;
DELETE FROM api_user_group WHERE solution_id=10005;
DELETE FROM api_user WHERE solution_id=10005;
DELETE FROM api_group WHERE solution_id=10005;
DELETE FROM api_event_handler WHERE solution_id=10005;
DELETE FROM api_table_view where solution_id=10005;
DELETE FROM api_ui_app_nav_item WHERE solution_id=10005;

/* Deinstall */
/*
alter table api_activity drop CONSTRAINT foreign_reference_api_activityproject_sprint_project_sprint_id;
alter table api_activity drop column project_sprint_id;
*/

/*
Tables
*/
CREATE TABLE IF NOT EXISTS project_activity_sprint_status(
    id int NOT NULL COMMENT '',
    name varchar(50) NOT NULL COMMENT '',
    created_on datetime NOT NULL DEFAULT current_timestamp COMMENT '',
    PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS project_activity_sprint(
    id int NOT NULL AUTO_INCREMENT COMMENT '',
    name varchar(250) NOT NULL COMMENT '',
    from_date datetime NULL COMMENT '',
    until_date datetime NULL COMMENT '',
    status_id int NOT NULL DEFAULT '100' COMMENT '',
    created_on datetime NOT NULL DEFAULT current_timestamp COMMENT '',
    CONSTRAINT `foreign_reference_project_activity_sprint_status_id` FOREIGN KEY(status_id) REFERENCES project_activity_sprint_status(id),
    PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS project_activity_actual_cost(
    id int NOT NULL AUTO_INCREMENT COMMENT '',
    activity_id int NOT NULL COMMENT '',
    cost decimal(15,4) NOT NULL DEFAULT '0' COMMENT '',
    currency_id int NOT NULL COMMENT '',
    remark varchar(250) NOT NULL COMMENT '',
    booking_date datetime NOT NULL COMMENT '',
    created_on datetime NOT NULL DEFAULT current_timestamp COMMENT '',
    CONSTRAINT `fr_project_activity_actual_cost_currency_id_api_activity_id` FOREIGN KEY(activity_id) REFERENCES api_activity(id),
    CONSTRAINT `fr_project_activity_actual_cost_currency_id_api_currency_id` FOREIGN KEY(currency_id) REFERENCES api_currency(id),
    PRIMARY KEY(id)    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE api_activity ADD column IF NOT EXISTS project_sprint_id int NULL COMMENT '';
ALTER TABLE `api_activity` ADD CONSTRAINT `foreign_reference_api_activityproject_sprint_project_sprint_id` FOREIGN KEY IF NOT EXISTS (`project_sprint_id`) REFERENCES `project_activity_sprint` (`id`);

/* Data */
INSERT IGNORE INTO project_activity_sprint_status (id, name) VALUES (1, 'Planning');
INSERT IGNORE INTO project_activity_sprint_status (id, name) VALUES (2, 'Running');
INSERT IGNORE INTO project_activity_sprint_status (id, name) VALUES (3, 'Closed');

/*
Meta Data
*/
INSERT IGNORE INTO api_solution(id,name) VALUES (10005, 'Agile Projectmanagement');
INSERT IGNORE INTO api_user (id,username,password,is_admin,disabled,solution_id) VALUES (100050001,'project','password',0,0,10005);
INSERT IGNORE INTO api_group(id,groupname,solution_id) VALUES (100050001,'project',10005);
INSERT IGNORE INTO api_user_group(user_id,group_id,solution_id) VALUES (100050001,100050001,10005);

INSERT IGNORE INTO api_table(id,alias,table_name,id_field_name,id_field_type,desc_field_name,enable_audit_log,solution_id)
    VALUES
    (100050001,'project_activity_sprint_status','project_activity_sprint_status','id','int','name',-1,10005);

INSERT IGNORE INTO api_table(id,alias,table_name,id_field_name,id_field_type,desc_field_name,enable_audit_log,solution_id)
    VALUES
    (100050002,'project_activity_sprint','project_activity_sprint','id','int','name',-1,10005);

INSERT IGNORE INTO api_table(id,alias,table_name,id_field_name,id_field_type,desc_field_name,enable_audit_log,solution_id)
    VALUES
    (100050003,'project_activity_actual_cost','project_activity_actual_cost','id','int','remark',-1,10005);

call api_proc_create_table_field_instance(100050002,10, 'id','ID', 'int',14,'{"disabled": true}', @out_value);
call api_proc_create_table_field_instance(100050002,20, 'name','Name', 'string',1,'{"disabled": false}', @out_value);
call api_proc_create_table_field_instance(100050002,30, 'from_date','Gültig von', 'datetime',9,'{"disabled": false}', @out_value);
call api_proc_create_table_field_instance(100050002,40, 'until_date','Gültig bis', 'datetime',9,'{"disabled": false}', @out_value);
call api_proc_create_table_field_instance(100050002,50, 'status_id','Status', 'int',2,'{"disabled": false}', @out_value);
call api_proc_create_table_field_instance(100050002,60, 'created_on','Erstellt', 'datetime',9,'{"disabled": true}', @out_value);

call api_proc_create_table_field_instance(100050001,10, 'id','ID', 'int',14,'{"disabled": true}', @out_value);
call api_proc_create_table_field_instance(100050001,20, 'name','Name', 'string',1,'{"disabled": false}', @out_value);
call api_proc_create_table_field_instance(100050001,30, 'created_on','Erstellt', 'datetime',9,'{"disabled": true}', @out_value);

call api_proc_create_table_field_instance(100050003,10, 'id','ID', 'int',14,'{"disabled": true}', @out_value);
call api_proc_create_table_field_instance(100050003,20, 'activity_id','Aktivität', 'int',2,'{"disabled": false}', @out_value);
call api_proc_create_table_field_instance(100050003,30, 'cost','Kosten', 'int',14,'{"disabled": false}', @out_value);
call api_proc_create_table_field_instance(100050003,40, 'currency_id','Wkz', 'int',2,'{"disabled": false}', @out_value);
UPDATE api_table_field SET default_value=1 WHERE id=@out_value;
call api_proc_create_table_field_instance(100050003,50, 'remark','Bemerkung', 'string',1,'{"disabled": false}', @out_value);

call api_proc_create_table_field_instance(100050003,60, 'booking_date','Buchngsdatum', 'datetime',9,'{"disabled": false}', @out_value);
UPDATE api_table_field SET default_value='current_timestamp()' WHERE id=@out_value;

call api_proc_create_table_field_instance(100050003,70, 'created_on','Erstellt', 'datetime',9,'{"disabled": true}', @out_value);




call api_proc_create_table_field_instance(44,9000, 'project_sprint_id','Sprint (Project)','int',2,'{"disabled": false}', @out_value);
call api_proc_create_table_field_instance(44,9010, '_costs','Kosten','string',200,'{"relation_type": "easy","columns":"id,cost,remark"}', @out_value);
UPDATE api_table_field
    SET is_virtual=-1, field_name='id',referenced_table_name='project_activity_actual_cost',referenced_table_id=100050003,referenced_field_name='activity_id'
    WHERE id=@out_value;



INSERT IGNORE INTO api_ui_app_nav_item(id, app_id,name,url,type_id,solution_id) VALUES (
100050001,4,'Sprints','/ui/v1.0/data/view/project_activity_sprint/default',1,10005);



INSERT IGNORE INTO api_table_view (id,type_id,name,table_id,id_field_name,solution_id,fetch_xml, columns) VALUES (
100050001,'LISTVIEW','default',100050003,'id',10005,'<restapi type="select">
    <table name="project_activity_actual_cost" alias="a"/>
    <orderby>
        <field name="id" alias="a" sort="ASC"/>
    </orderby>
</restapi>',
'{"id": {}, "name": {},"__activity_id@name":{}, "cost":{},"__currency_id@name":{}, "remark": {} }');

INSERT IGNORE INTO api_table_view (id,type_id,name,table_id,id_field_name,solution_id,fetch_xml, columns) VALUES (
100050002,'LISTVIEW','default',100050002,'id',10005,'<restapi type="select">
    <table name="project_activity_sprint" alias="s"/>
    <orderby>
        <field name="id" alias="s" sort="ASC"/>
    </orderby>
</restapi>',
'{"id": {}, "name": {} }');


/* Portal */
INSERT IGNORE INTO api_portal (id,name, template, solution_id) VALUES (
    'project_task_board', 'Projekt Aufgaben', NULL, 10005
);

UPDATE api_portal SET template='<!DOCTYPE html>
<html lang="en">
<head>
<style>
html, body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    display: flex;
    min-height: 100vh;
    background-color: #f4f4f4;
    margin-top: 1vh;
    height: 90vh;
	min-width: 100%;
    overflow-y: hidden;
}

.kanban-board {
    display: flex;
    overflow-x: auto;
    padding: 20px;
}

.column {
    flex: 1;
    min-width: 200px;
    border-radius: 3px;
    margin-right: 5px;
    box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
    padding: 10px;
    box-sizing: border-box;
    overflow-y: scroll;
}

.backlog {
    background-color: rgb(250, 248, 248);
    border: 2px solid #bdbbbb;
    .column-header {
        color: #3498db;
    }
}

.column-header {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 10px;
}

.task {
    background-color: #ffffff;
    border-color: #bdbbbb;
    border-radius: 5px;
    padding: 0px;
    margin-bottom: 1px;
    cursor: grab;
    transition: transform 0.3s ease-in-out;
    display: flex;
    
    .dragging {
        transform: scale(1.1);
        }
    }

.task-image-column {
    width: 5px; 
    margin-right: 10px;
    background-color: #51f759; 
    border-radius: 5px;
}

.task-image {
    width: 100%;
    height: auto;
    border-radius: 5px;
}

.task-details {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.task-title {
    font-size: 16px;
    font-weight: bold;
    margin-bottom: 5px;
}

.task-details-text {
    font-size: 14px;
}
</style>

<script language="javascript">
    let draggedTask;
    
    function onChangeDataStatus(status, msg) {}

    function drag(event) {
        onChangeDataStatus(true, \'\');
        
        draggedTask = event.target;
        draggedTask.classList.add("dragging");
    }
    
    function allowDrop(event) {
        event.preventDefault();
    }
    
    function drop(event) {
        event.preventDefault();
        const targetColumnId = event.target.closest(".column").id;
        const targetColumn = document.getElementById(targetColumnId);
        targetColumn.appendChild(draggedTask);
        draggedTask.classList.remove("dragging");

        // Update the database
        var activityId=draggedTask.id.split(\'_\')[1];
        var activityType=draggedTask.id.split(\'_\')[0];
        var targetLaneId=targetColumnId.split(\'_\')[1];
        var data=JSON.stringify({
            id: activityId,
            lane_id: targetLaneId
        });
        xmlHttpRequest("PUT", `/api/v1.0/data/api_activity/${activityId}`,"tag", data, function(tag, data) {onChangeDataStatus(false, \'\');})
    }
    
    const backlogTasks = [];
    const todoTasks = [];
    const inProgressTasks = [];
    const doneTasks = [];
    
    function generateLanes(lanes) {
        return lanes
            .map((lane) => {
                return `
                <div class="column backlog" ondrop="drop(event)" ondragover="allowDrop(event)" id="lane_${lane.id}">
                <div class="column-header">${lane.name}</div>
                </div>
            `;
            })
            .join("");
    }



    function generateTasksElements(tasks) {
        return tasks
            .map((task) => {
                return `
              <div class="task" draggable="true" ondragstart="drag(event)" id="item_${task.id}">
                <div class="task-image-column" style="background-color: ${task[\'__due_date_color@formatted_value\']};"></div>
                <div class="task-details">
                  <div class="task-title">${task.subject}</div>
                  <div class="task-details-text">${task[\'__board_id@name\']}</div>
                  <div class="task-details-text">${task[\'__due_date@formatted_value\']}</div>
                  <div class="task-details-text">${task[\'__status_id@name\']}</div>
                  <!--<div style="background-color: silver;" class="task-details-text">${task.msg_text}</div>-->
                  <div class="task-details-text"><a href="/api/v1.0/data/api_activity/${task[\'id\']}?view=$default_ui" target="_blank">Bearbeiten</a></div>
                </div>
              </div>
            `;
            })
            .join("");
    }
    
    function xmlHttpRequest(method, url, tag, data, callBack) {
        const xhr = new XMLHttpRequest();
        xhr.open(method, url);
        if (data!=undefined) {
            xhr.setRequestHeader("Content-Type", "application/json; charset=UTF-8");
        }
        xhr.responseType = "json";
        xhr.onload = () => {
            if (xhr.readyState == 4 && xhr.status == 200) {
                const data = xhr.response;
                callBack(tag, data);
                console.log(data);
            } else {
                console.log(`Error: ${xhr.status}`);
                alert(xhr.statusText);
            }
        };
        xhr.send(data);
    }

	function loadLanes() {
		xmlHttpRequest("GET", "/api/v1.0/data/api_activity_lane","main_board",undefined, function(tag, data) {
			document.getElementById(tag).innerHTML = generateLanes(data);

			data.forEach(element => {
				var fetchXml=`<restapi type="select">
					<filter type="AND">
						<condition field="type_id" value="1" operator="neq"/>
						<condition field="status_id" value="100" operator="neq"/>
						<condition field="lane_id" value="${element[\'id\']}" operator="eq"/>
					</filter>
					<orderby>
						<field name="due_date" sort="ASC"/>
					</orderby>
				</restapi>`;
				xmlHttpRequest("POST", "/api/v1.0/data/search/api_activity",`lane_${element.id}`,fetchXml, function(tag, data) {
					document.getElementById(tag).innerHTML = document.getElementById(tag).innerHTML + generateTasksElements(data);
			});
				
			});
		});	
	}
    </script>


</head>
<body>

        <div id="content">
        </div>

<div class="kanban-board" id="main_board" style="width: 100%">
	<!-- Hier der Main Content! -->
	{{ content }}
	<!-- ende Content -->

    <div class="column backlog" ondrop="drop(event)" ondragover="allowDrop(event)" id="lane_1">
      <div class="column-header">Plaese wait ...</div>
    </div>
</div>

<script language="javascript">
    loadLanes();
</script>

</body>
</html>' WHERE id='project_task_board';