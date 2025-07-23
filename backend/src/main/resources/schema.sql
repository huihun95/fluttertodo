-- 태스크 할당 시스템을 위한 데이터베이스 스키마

-- Users 테이블
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TodoTasks 테이블 (TaskModel 기반)
CREATE TABLE IF NOT EXISTS todo_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    requester_id UUID REFERENCES users(id) ON DELETE SET NULL, -- 할당한 사람
    assignee_id UUID REFERENCES users(id) ON DELETE CASCADE,   -- 할당받은 사람
    status VARCHAR(50) DEFAULT 'PENDING',   -- PENDING, IN_PROGRESS, COMPLETED, CANCELLED
    deadline TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications 테이블 (알림 시스템)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,     -- 알림 받을 사람
    task_id UUID REFERENCES todo_tasks(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,              -- TASK_ASSIGNED, TASK_COMPLETED, TASK_UPDATED, TASK_CANCELLED
    title VARCHAR(255) NOT NULL,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task History 테이블 (상태 변경 추적)
CREATE TABLE IF NOT EXISTS task_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES todo_tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,     -- 변경한 사람
    previous_status VARCHAR(50),
    new_status VARCHAR(50),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_todo_tasks_requester ON todo_tasks(requester_id);
CREATE INDEX IF NOT EXISTS idx_todo_tasks_assignee ON todo_tasks(assignee_id);
CREATE INDEX IF NOT EXISTS idx_todo_tasks_status ON todo_tasks(status);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_task_history_task ON task_history(task_id);
CREATE INDEX IF NOT EXISTS idx_task_history_user ON task_history(user_id);