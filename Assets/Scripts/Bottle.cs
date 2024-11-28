using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bottle : MonoBehaviour
{
    public Renderer bottleMaterial; // Reference to the renderer component on the bottle
    private Material materialInstance; // To store the material instance for each bottle
    public Rigidbody rb; // Reference to the Rigidbody of the bottle //

    // Impact stress parameters
    private float impactMagnitude = 0.0f; // The current impact force/stress
    private float targetImpactMagnitude = 0.0f; // The target stress level from the latest impact
    public float stressDecayRate = 1.0f; // Controls how fast the stress smooths out
    public float maxImpact = 0.1f; // Maximum stress (wave height, speed, etc.)

    // Current wave parameters that will be smoothed
    private float currentWaveSpeed;
    private float currentWaveHeight;
    private float currentWaveFrequency;

    // Amplification variables to increase the effect
    public float waveSpeedMultiplier = 1.0f; // Multiplier for wave speed effect
    public float waveHeightMultiplier = 1.0f; // Multiplier for wave height effect
    public float waveFrequencyMultiplier = 1.0f; // Multiplier for wave frequency effect

    // Optionally, you can introduce a time-based factor to gradually amplify the effect
    public float timeMultiplierIncreaseRate = 0.1f; // Rate at which the multipliers increase over time
    private float elapsedTime = 0.0f; // Track elapsed time for gradual multiplier increase

    // Start is called before the first frame update
    void Start()
    {
        // Create a new material instance to ensure it's unique to this bottle
        materialInstance = new Material(bottleMaterial.materials[0]);

        // Assign the new material instance to the renderer
        bottleMaterial.materials[0] = materialInstance;

        // Get the Rigidbody component attached to the bottle
        //rb = GetComponent<Rigidbody>();

        // Initialize wave parameters
        currentWaveSpeed = 0.0f;
        currentWaveHeight = 0.0f;
        currentWaveFrequency = 0.0f;
    }

    // Update is called once per frame
    void Update()
    {
        // Update the y position of the bottle shader
        bottleMaterial.materials[0].SetFloat("_AbsolutePositionY", transform.position.y);

        // Update the impact stress and smooth wave properties
        UpdateImpactAndWaterMotion();

        // Optionally, increase the multiplier over time to amplify the effect
        IncreaseMultiplierOverTime();
    }

    // Method to update the impact and water wave properties with stress smoothing
    void UpdateImpactAndWaterMotion()
    {
        // Get the velocity of the Rigidbody to determine the impact
        Vector3 velocity = rb.velocity;

        // Calculate the magnitude of the impact (how fast the bottle is moving)
        float impact = Mathf.Abs(velocity.magnitude);

        // If the impact exceeds a threshold, we register it as an impact and apply stress
        if (impact > 0.1f) // You can adjust this threshold to determine how sensitive the system is
        {
            // Apply the impact as stress to the water
            targetImpactMagnitude = Mathf.Clamp(impact * 0.05f, 0.0f, maxImpact); // Scale the impact to a reasonable value
        }

        // Smoothly interpolate (lerp) towards the target stress value to simulate the gradual decay of the impact
        impactMagnitude = Mathf.Lerp(impactMagnitude, targetImpactMagnitude, Time.deltaTime * stressDecayRate);

        // Calculate wave parameters based on the current stress (impact magnitude) and multipliers
        currentWaveSpeed = Mathf.Lerp(currentWaveSpeed, impactMagnitude * 50.0f * waveSpeedMultiplier, Time.deltaTime * stressDecayRate); // Example scaling
        currentWaveHeight = Mathf.Lerp(currentWaveHeight, impactMagnitude * 0.02f * waveHeightMultiplier, Time.deltaTime * stressDecayRate); // Example scaling
        currentWaveFrequency = Mathf.Lerp(currentWaveFrequency, impactMagnitude * 5.0f * waveFrequencyMultiplier, Time.deltaTime * stressDecayRate); // Example scaling

        // Set the smoothed wave parameters in the shader
        bottleMaterial.materials[0].SetFloat("_WaveSpeed", currentWaveSpeed);
        bottleMaterial.materials[0].SetFloat("_WaveHeight", currentWaveHeight);
        bottleMaterial.materials[0].SetFloat("_WaveFrequency", currentWaveFrequency);
    }

    // Optionally increase multipliers over time
    void IncreaseMultiplierOverTime()
    {
        // Increase the multipliers over time, this can be customized based on the game's needs
        elapsedTime += Time.deltaTime;

        waveSpeedMultiplier = 1.0f + timeMultiplierIncreaseRate * elapsedTime; // Gradually increase the wave speed multiplier
        waveHeightMultiplier = 1.0f + timeMultiplierIncreaseRate * elapsedTime; // Gradually increase the wave height multiplier
        waveFrequencyMultiplier = 1.0f + timeMultiplierIncreaseRate * elapsedTime; // Gradually increase the wave frequency multiplier
    }
}
