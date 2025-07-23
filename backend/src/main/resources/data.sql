-- 샘플 데이터 삽입 (테스트용)

-- 샘플 사용자들
INSERT INTO users (id, email, password, name) VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'admin@example.com', '$2a$10$9wJfUoC.FJz0OmH.mF3Df.N1gJA8.X2Ey1F5qV.F8H.yJy4Z.YzBu', '관리자'),
('550e8400-e29b-41d4-a716-446655440002', 'user1@example.com', '$2a$10$9wJfUoC.FJz0OmH.mF3Df.N1gJA8.X2Ey1F5qV.F8H.yJy4Z.YzBu', '김개발'),
('550e8400-e29b-41d4-a716-446655440003', 'user2@example.com', '$2a$10$9wJfUoC.FJz0OmH.mF3Df.N1gJA8.X2Ey1F5qV.F8H.yJy4Z.YzBu', '이디자인')
ON CONFLICT (email) DO NOTHING;

-- 샘플 태스크들
INSERT INTO todo_tasks (id, title, content, requester_id, assignee_id, status, deadline) VALUES 
('660e8400-e29b-41d4-a716-446655440001', 'Flutter 앱 UI 개선', 'TODO 앱의 메인 화면 UI를 개선해주세요.', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'PENDING', '2025-08-01 23:59:59'),
('660e8400-e29b-41d4-a716-446655440002', '백엔드 API 테스트', '태스크 할당 API의 테스트 케이스를 작성해주세요.', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'IN_PROGRESS', '2025-07-30 18:00:00'),
('660e8400-e29b-41d4-a716-446655440003', '디자인 시안 검토', '새로운 로고 디자인 시안을 검토하고 피드백 부탁드립니다.', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', 'COMPLETED', '2025-07-25 17:00:00')
ON CONFLICT (id) DO NOTHING;

-- 샘플 알림들
INSERT INTO notifications (user_id, task_id, type, title, message) VALUES 
('550e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001', 'TASK_ASSIGNED', '새로운 태스크가 할당되었습니다', '관리자님이 "Flutter 앱 UI 개선" 태스크를 할당했습니다.'),
('550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440003', 'TASK_COMPLETED', '태스크가 완료되었습니다', '이디자인님이 "디자인 시안 검토" 태스크를 완료했습니다.'),
('550e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440003', 'TASK_ASSIGNED', '새로운 태스크가 할당되었습니다', '관리자님이 "디자인 시안 검토" 태스크를 할당했습니다.')
ON CONFLICT DO NOTHING;

-- 샘플 태스크 히스토리
INSERT INTO task_history (task_id, user_id, previous_status, new_status, comment) VALUES 
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'PENDING', 'IN_PROGRESS', '작업을 시작합니다.'),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'PENDING', 'IN_PROGRESS', '검토를 시작합니다.'),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'IN_PROGRESS', 'COMPLETED', '검토 완료했습니다. 전반적으로 좋은 디자인입니다.')
ON CONFLICT DO NOTHING;