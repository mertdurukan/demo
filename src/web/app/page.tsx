'use client';

import { useState } from 'react';
import styles from './page.module.css';

export default function Home() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [message, setMessage] = useState('');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userData, setUserData] = useState<{userId: number, username: string} | null>(null);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // ÖNCE TÜM STATE'LERİ SIFIRLA - GÜVENLİK AÇIĞI ÖNLEMİ
    setIsLoggedIn(false);
    setUserData(null);
    setMessage('Giriş kontrol ediliyor...');
    
    // API bağlantısını zorunlu hale getir
    let loginSuccess = false;
    let responseData = null;
    
    try {
      console.log('API çağrısı başlatılıyor...');
      
      const apiUrl = process.env.NODE_ENV === 'production' 
        ? process.env.API_URL || 'http://localhost:5102'
        : 'http://localhost:5102';
      
      const response = await fetch(`${apiUrl}/api/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          username,
          password,
        }),
      });

      console.log('API yanıtı alındı:', response.status, response.statusText);

      // Sadece 200 OK durumunda devam et
      if (response.status === 200) {
        try {
          responseData = await response.json();
          console.log('API yanıt verisi:', responseData);
          
          // Zorunlu alan kontrolü
          if (responseData && 
              typeof responseData.userId === 'number' && 
              typeof responseData.username === 'string' && 
              responseData.userId > 0 && 
              responseData.username.length > 0) {
            loginSuccess = true;
          } else {
            console.error('API yanıtı geçersiz veri içeriyor:', responseData);
            setMessage('Sunucudan geçersiz kullanıcı verisi alındı');
          }
        } catch (jsonError) {
          console.error('JSON parse hatası:', jsonError);
          setMessage('Sunucu yanıtı okunamadı');
        }
      } else {
        // HTTP hata durumu
        let errorMessage = 'Giriş başarısız';
        try {
          const errorData = await response.json();
          errorMessage = errorData.message || `HTTP ${response.status}: ${response.statusText}`;
        } catch {
          errorMessage = `HTTP ${response.status}: ${response.statusText}`;
        }
        console.error('HTTP hatası:', response.status, errorMessage);
        setMessage(errorMessage);
      }
      
    } catch (networkError) {
      // Ağ bağlantı hatası - API'ye ulaşılamıyor
      console.error('Ağ bağlantı hatası:', networkError);
      setMessage('API sunucusuna bağlanılamıyor! Sunucunun çalıştığından emin olun.');
    }
    
    // SADECE VE SADECE BAŞARILI API YANITI VARSA GİRİŞ YAP
    if (loginSuccess && responseData) {
      console.log('Giriş başarılı, state güncelleniyor...');
      setMessage(responseData.message || 'Giriş başarılı');
      setIsLoggedIn(true);
      setUserData({ 
        userId: responseData.userId, 
        username: responseData.username 
      });
    } else {
      // Başarısız durumda kesinlikle giriş yapma
      console.log('Giriş başarısız, state sıfırlanıyor...');
      setIsLoggedIn(false);
      setUserData(null);
      // Message yoksa varsayılan hata mesajı
      setTimeout(() => {
        setMessage(prevMessage => prevMessage || 'Giriş yapılamadı');
      }, 100);
    }
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setUserData(null);
    setUsername('');
    setPassword('');
    setMessage('');
  };

  if (isLoggedIn && userData) {
    return (
      <div className={styles.page}>
        <main className={styles.main}>
          <div className={styles.loginContainer}>
            <h1>Hoş Geldiniz!</h1>
            <div className={styles.userInfo}>
              <p><strong>Kullanıcı ID:</strong> {userData.userId}</p>
              <p><strong>Kullanıcı Adı:</strong> {userData.username}</p>
            </div>
            <button 
              onClick={handleLogout}
              className={styles.logoutButton}
            >
              Çıkış Yap
            </button>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <div className={styles.loginContainer}>
          <h1>Kullanıcı Girişi</h1>
          <form onSubmit={handleLogin} className={styles.loginForm}>
            <div className={styles.formGroup}>
              <label htmlFor="username">Kullanıcı Adı:</label>
              <input
                type="text"
                id="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
                className={styles.input}
              />
            </div>
            <div className={styles.formGroup}>
              <label htmlFor="password">Şifre:</label>
              <input
                type="password"
                id="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className={styles.input}
              />
            </div>
            <button type="submit" className={styles.loginButton}>
              Giriş Yap
            </button>
          </form>
          {message && (
            <div className={`${styles.message} ${isLoggedIn ? styles.success : styles.error}`}>
              {message}
            </div>
          )}
          <div className={styles.credentials}>
            <p><strong>Test Bilgileri:</strong></p>
            <p>Kullanıcı Adı: admin</p>
            <p>Şifre: 123456</p>
          </div>
        </div>
      </main>
    </div>
  );
}
