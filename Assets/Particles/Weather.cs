using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
namespace APIExample
{
    public class Weather : MonoBehaviour
    {
        void Start()
        {
            StartCoroutine(GetText());
        }
        IEnumerator GetText()
        {
            UnityWebRequest www = UnityWebRequest.Get("https://api.openweathermap.org/data/2.5/weather?q=Mexico,mx&appid=93f45e51354871222b9d90fe7937a82e");
            yield return www.SendWebRequest();
            if (www.isNetworkError || www.isHttpError)
            {
                Debug.Log(www.error);
            }
            else
            {
                Debug.Log(www.downloadHandler.text);
                string result = www.downloadHandler.text;
                WeatherContainer node = JsonUtility.FromJson<WeatherContainer>(result);
                Debug.Log("Weather: " + node.weather[0].main);
                //byte[] results = www.downloadHandler.data;
            }
        }
    }
    [Serializable]
    public class WeatherContainer
    {
        public weather[] weather;
    }

    [Serializable]
    public class weather
    {
        public int id;
        public string main, description, icon;

    }


}

