import { useState, useEffect, useRef, useCallback } from 'react';
import { quizApi } from '../services/api';
import { useApp } from '../context/AppContext';

const LOCAL_QUESTIONS = [
  { id: 'q1', position: 1, type: 'song_clue', difficulty: 'easy', question_text: "Ee movie lo 'Naatu Naatu' song vasindi?", options: { a: 'Baahubali', b: 'RRR', c: 'Pushpa', d: 'Magadheera' }, time_limit_seconds: 15, coins_reward: 3, img: '🎶' },
  { id: 'q2', position: 2, type: 'hero_silhouette', difficulty: 'medium', question_text: 'Mahesh Babu hero ga first movie?', options: { a: 'Raja Kumarudu', b: 'Neeku Naaku Naidu', c: 'Murari', d: 'Okkadu' }, time_limit_seconds: 12, coins_reward: 4, img: '👑' },
  { id: 'q3', position: 3, type: 'movie_still', difficulty: 'easy', question_text: 'Pushpa lo hero enti?', options: { a: 'Mahesh', b: 'Allu Arjun', c: 'NTR', d: 'Prabhas' }, time_limit_seconds: 15, coins_reward: 3, img: '🔥' },
  { id: 'q4', position: 4, type: 'release_year', difficulty: 'easy', question_text: 'RRR movie release year enti?', options: { a: '2020', b: '2021', c: '2022', d: '2023' }, time_limit_seconds: 15, coins_reward: 3, img: '📅' },
  { id: 'q5', position: 5, type: 'dialogue', difficulty: 'hard', question_text: 'SS Rajamouli director ga first blockbuster?', options: { a: 'Magadheera', b: 'Vikramarkudu', c: 'Student No 1', d: 'Simhadri' }, time_limit_seconds: 10, coins_reward: 5, img: '💬' },
];

const LOCAL_CORRECT = { q1: 'b', q2: 'a', q3: 'b', q4: 'c', q5: 'a' };

export function useQuiz() {
  const { isLoggedIn, refreshCoinBalance } = useApp();
  const [questions, setQuestions] = useState([]);
  const [currentIdx, setCurrentIdx] = useState(0);
  const [answered, setAnswered] = useState(null);
  const [score, setScore] = useState(0);
  const [timer, setTimer] = useState(15);
  const [sessionId, setSessionId] = useState(null);
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(false);
  const timerRef = useRef(null);
  const startTimeRef = useRef(null);
  const questionStartRef = useRef(null);

  const clearTimer = useCallback(() => clearInterval(timerRef.current), []);

  const initQuiz = useCallback(async () => {
    setLoading(true);
    setCurrentIdx(0);
    setAnswered(null);
    setScore(0);
    setResults(null);

    try {
      if (isLoggedIn) {
        const data = await quizApi.getToday();
        if (data.already_completed) {
          setResults({ already_completed: true, score: data.session_score });
          setLoading(false);
          return;
        }
        const session = await quizApi.startSession();
        setSessionId(session.session_id);
        setQuestions(data.questions);
      } else {
        setQuestions(LOCAL_QUESTIONS);
      }
    } catch (_) {
      setQuestions(LOCAL_QUESTIONS);
    }

    startTimeRef.current = Date.now();
    setLoading(false);
  }, [isLoggedIn]);

  const currentQuestion = questions[currentIdx];

  useEffect(() => {
    if (!currentQuestion || answered !== null) return;
    const limit = currentQuestion.time_limit_seconds || 15;
    setTimer(limit);
    questionStartRef.current = Date.now();
    clearTimer();
    timerRef.current = setInterval(() => {
      setTimer(t => {
        if (t <= 1) {
          clearTimer();
          handleAnswer(null);
          return 0;
        }
        return t - 1;
      });
    }, 1000);
    return clearTimer;
  }, [currentIdx, answered, currentQuestion]);

  const handleAnswer = useCallback(async (option) => {
    if (answered !== null) return;
    clearTimer();
    const timeTakenMs = Date.now() - (questionStartRef.current || Date.now());
    setAnswered(option);

    let isCorrect = false;

    if (isLoggedIn && sessionId && currentQuestion) {
      try {
        const result = await quizApi.submitAnswer(sessionId, currentQuestion.id, option, timeTakenMs);
        isCorrect = result.is_correct;
      } catch (_) {
        isCorrect = option === LOCAL_CORRECT[currentQuestion.id];
      }
    } else {
      isCorrect = option === LOCAL_CORRECT[currentQuestion?.id];
    }

    if (isCorrect) setScore(s => s + 1);

    setTimeout(async () => {
      if (currentIdx < questions.length - 1) {
        setCurrentIdx(i => i + 1);
        setAnswered(null);
      } else {
        // Complete quiz
        const totalMs = Date.now() - (startTimeRef.current || Date.now());
        let finalScore = score + (isCorrect ? 1 : 0);

        if (isLoggedIn && sessionId) {
          try {
            const res = await quizApi.completeSession(sessionId, totalMs);
            setResults(res);
            await refreshCoinBalance();
            return;
          } catch (_) {}
        }

        const coins = finalScore === 5 ? 25 : finalScore === 4 ? 15 : finalScore === 3 ? 5 : 0;
        setResults({ score: finalScore, total: 5, coins_earned: coins, streak: 1 });
      }
    }, 900);
  }, [answered, currentIdx, questions.length, isLoggedIn, sessionId, currentQuestion, score, refreshCoinBalance, clearTimer]);

  return {
    questions, currentQuestion, currentIdx, answered, score, timer,
    results, loading, handleAnswer, initQuiz,
  };
}
