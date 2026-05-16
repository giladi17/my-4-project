# --- Stage 1: Builder ---
# אנחנו משתמשים בגרסה קלה של פייתון
FROM python:3.9-slim AS builder

# הגדרת תיקיית העבודה בתוך הקונטיינר
WORKDIR /app

# העתקת קובץ התלויות בלבד בשלב זה כדי לנצל את מנגנון הקאש של דוקר
COPY requirements.txt .

# התקנת הספריות לתוך תיקיית משתמש מקומית כדי שנוכל להעתיק אותן בקלות לשלב הבא
RUN pip install --user --no-cache-dir -r requirements.txt

# --- Stage 2: Runner ---
# מתחילים תמונה חדשה ונקייה לגמרי
FROM python:3.9-slim AS runner

# הגדרת תיקיית העבודה
WORKDIR /app

# העתקת הספריות שהותקנו מהשלב הקודם (הבנאי) אל התמונה החדשה
COPY --from=builder /root/.local /root/.local

# העתקת קוד האפליקציה שלנו (app.py, test_app.py)
COPY . .

# עדכון משתני סביבה כדי שפייתון יכיר בנתיב שבו הותקנו הספריות
ENV PATH=/root/.local/bin:$PATH

# חשיפת הפורט שעליו האפליקציה רצה
EXPOSE 5000

# הפקודה שתריץ את האפליקציה כשהקונטיינר עולה
CMD ["python", "app.py"]